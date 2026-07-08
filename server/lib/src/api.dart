import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'config.dart';
import 'db.dart';
import 'dto.dart';
import 'file_store.dart';
import 'realtime.dart';
import 'tokens.dart';

/// Types d'évènements de synchronisation portant l'état complet d'un agrégat.
/// Doivent rester alignés avec le client (`ShoppingEvents`/`DocumentEvents`).
const _shoppingSync = 'shopping.sync';
const _documentSync = 'document.sync';
const _taskSync = 'task.sync';
const _gallerySync = 'gallery.sync';
const _gardenSync = 'garden.sync';

/// Assemble le routeur HTTP + WebSocket. `clock` injectable pour les tests.
class Api {
  Api({
    required this.db,
    required this.tokens,
    required this.hub,
    required this.files,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final Db db;
  final Tokens tokens;
  final RealtimeHub hub;
  final FileStore files;
  final DateTime Function() _now;

  factory Api.fromConfig(ServerConfig config) => Api(
        db: Db.open(config.dbPath),
        tokens: Tokens(config.jwtSecret),
        hub: RealtimeHub(),
        files: FileStore(config.filesDir),
      );

  Handler get handler {
    final router = Router()
      ..post('/auth/register', _register)
      ..post('/auth/login', _login)
      ..get('/auth/me', _me)
      ..get('/household', _household)
      ..get('/shopping', _getShopping)
      ..put('/shopping', _putShopping)
      ..get('/documents', _getDocuments)
      ..post('/documents/files', _uploadFile)
      ..get('/documents/files/<fileId>', _getFile)
      ..get('/realtime', _realtime)
      ..get('/health', (Request _) => _json({'ok': true}));

    // Auth appliquée aux routes protégées uniquement (les publiques la sautent).
    return const Pipeline().addMiddleware(_authMiddleware).addHandler(router.call);
  }

  String _iso() => _now().toUtc().toIso8601String();

  // --- Auth -----------------------------------------------------------------

  Future<Response> _register(Request request) async {
    final body = await _body(request);
    final email = (body['email'] as String?)?.trim();
    final password = body['password'] as String?;
    final displayName = (body['displayName'] as String?)?.trim();
    final joinCode = (body['joinCode'] as String?)?.trim();
    if (_blank(email) || _blank(displayName) || (password?.length ?? 0) < 6) {
      return _error(400, 'Email, nom et mot de passe (≥6) requis');
    }
    if (db.userByEmail(email!) != null) {
      return _error(409, 'Email déjà utilisé');
    }
    final household = _resolveHousehold(joinCode, displayName!);
    if (household == null) return _error(400, 'Code de maison invalide');

    final user = db.createUser(
      email: email,
      passwordHash: BCrypt.hashpw(password!, BCrypt.gensalt()),
      displayName: displayName,
      householdId: household['id'] as String,
      nowIso: _iso(),
    );
    return _session(user, household);
  }

  /// Rejoint la maison du code fourni, ou en crée une nouvelle.
  Map<String, Object?>? _resolveHousehold(String? joinCode, String displayName) {
    if (joinCode != null && joinCode.isNotEmpty) {
      return db.householdByJoinCode(joinCode.toUpperCase());
    }
    return db.createHousehold('Maison de $displayName', _iso());
  }

  Future<Response> _login(Request request) async {
    final body = await _body(request);
    final email = (body['email'] as String?)?.trim();
    final password = body['password'] as String?;
    if (_blank(email) || _blank(password)) {
      return _error(400, 'Email et mot de passe requis');
    }
    final user = db.userByEmail(email!);
    if (user == null ||
        !BCrypt.checkpw(password!, user['password_hash'] as String)) {
      return _error(401, 'Identifiants invalides');
    }
    final household = db.householdById(user['household_id'] as String)!;
    return _session(user, household);
  }

  Response _session(Map<String, Object?> user, Map<String, Object?> household) {
    final token = tokens.issue(
      userId: user['id'] as String,
      householdId: household['id'] as String,
    );
    return _json({
      'token': token,
      'user': userDto(user),
      'household': householdDto(household, db),
    });
  }

  Response _me(Request request) {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final user = db.userById(auth.userId);
    if (user == null) return _error(401, 'Session invalide');
    final household = db.householdById(user['household_id'] as String)!;
    return _json({
      'user': userDto(user),
      'household': householdDto(household, db),
    });
  }

  Response _household(Request request) {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final household = db.householdById(auth.householdId);
    if (household == null) return _error(404, 'Maison introuvable');
    return _json(householdDto(household, db));
  }

  // --- Shopping -------------------------------------------------------------

  Response _getShopping(Request request) {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final list = db.shoppingList(auth.householdId) ??
        {'householdId': auth.householdId, 'categories': <dynamic>[]};
    return _json(list);
  }

  Future<Response> _putShopping(Request request) async {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final list = await _body(request);
    list['householdId'] = auth.householdId; // autorité serveur sur la maison
    db.saveShoppingList(auth.householdId, list, _iso());
    return _json({'ok': true});
  }

  // --- Documents --------------------------------------------------------------

  Response _getDocuments(Request request) {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final library = db.documentLibrary(auth.householdId) ??
        {'householdId': auth.householdId, 'tabs': <dynamic>[]};
    return _json(library);
  }

  /// Upload binaire brut (body = octets de l'image, `?ext=jpg`). Renvoie
  /// l'id de fichier à référencer dans les métadonnées du document.
  Future<Response> _uploadFile(Request request) async {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final ext = request.url.queryParameters['ext'] ?? 'jpg';
    final bytes = await _readBytes(request);
    if (bytes.isEmpty) return _error(400, 'Fichier vide');
    final fileId = await files.save(auth.householdId, ext, bytes);
    if (fileId == null) return _error(400, 'Type de fichier non autorisé');
    return _json({'fileId': fileId});
  }

  Response _getFile(Request request, String fileId) {
    final auth = _auth(request);
    if (auth == null) return _error(401, 'Non authentifié');
    final file = files.find(auth.householdId, fileId);
    if (file == null) return _error(404, 'Fichier introuvable');
    return Response.ok(
      file.openRead(),
      headers: {
        'content-type': files.contentType(fileId),
        'cache-control': 'private, max-age=31536000, immutable',
      },
    );
  }

  Future<List<int>> _readBytes(Request request) async {
    final chunks = <int>[];
    await for (final chunk in request.read()) {
      chunks.addAll(chunk);
    }
    return chunks;
  }

  // --- WebSocket ------------------------------------------------------------

  Future<Response> _realtime(Request request) async {
    final token = request.url.queryParameters['token'];
    final auth = token == null ? null : tokens.verify(token);
    if (auth == null) return _error(401, 'Token WebSocket manquant/invalide');
    final ws = webSocketHandler(
      (WebSocketChannel channel, _) => _onSocket(channel, auth.householdId),
    );
    return await ws(request);
  }

  void _onSocket(WebSocketChannel channel, String householdId) {
    hub.join(householdId, channel);
    _sendCurrentState(channel, householdId);
    channel.stream.listen(
      (data) => _onMessage(channel, householdId, data),
      onDone: () => hub.leave(householdId, channel),
      onError: (_) => hub.leave(householdId, channel),
    );
  }

  /// À la connexion : pousse l'état courant de chaque agrégat persisté.
  void _sendCurrentState(WebSocketChannel channel, String householdId) {
    void send(String type, String key, Map<String, dynamic>? value) {
      if (value == null) return;
      channel.sink.add(jsonEncode({
        'type': type,
        'payload': {key: value},
      }));
    }

    send(_shoppingSync, 'list', db.shoppingList(householdId));
    send(_documentSync, 'library', db.documentLibrary(householdId));
    send(_taskSync, 'board', db.taskBoard(householdId));
    send(_gallerySync, 'album', db.galleryAlbum(householdId));
    send(_gardenSync, 'garden', db.garden(householdId));
  }

  void _onMessage(WebSocketChannel channel, String householdId, Object? data) {
    final message = _tryDecode(data);
    if (message == null) return;
    // Une sync porte l'état complet : on persiste (autorité serveur) puis diffuse.
    _persistSync(message, householdId);
    hub.broadcast(householdId, jsonEncode(message), channel);
  }

  void _persistSync(Map<String, dynamic> message, String householdId) {
    final payload = message['payload'];
    if (payload is! Map<String, dynamic>) return;
    switch (message['type']) {
      case _shoppingSync:
        final list = payload['list'];
        if (list is Map<String, dynamic>) {
          list['householdId'] = householdId;
          db.saveShoppingList(householdId, list, _iso());
        }
      case _documentSync:
        final library = payload['library'];
        if (library is Map<String, dynamic>) {
          library['householdId'] = householdId;
          db.saveDocumentLibrary(householdId, library, _iso());
        }
      case _taskSync:
        final board = payload['board'];
        if (board is Map<String, dynamic>) {
          board['householdId'] = householdId;
          db.saveTaskBoard(householdId, board, _iso());
        }
      case _gallerySync:
        final album = payload['album'];
        if (album is Map<String, dynamic>) {
          album['householdId'] = householdId;
          db.saveGalleryAlbum(householdId, album, _iso());
        }
      case _gardenSync:
        final garden = payload['garden'];
        if (garden is Map<String, dynamic>) {
          garden['householdId'] = householdId;
          db.saveGarden(householdId, garden, _iso());
        }
    }
  }

  Map<String, dynamic>? _tryDecode(Object? data) {
    if (data is! String) return null;
    try {
      final decoded = jsonDecode(data);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  // --- Middleware & helpers -------------------------------------------------

  /// Décode un éventuel Bearer token et le range dans le contexte de requête.
  /// N'échoue jamais : chaque handler décide si l'auth est requise.
  Middleware get _authMiddleware => (Handler inner) {
        return (Request request) {
          final header = request.headers['authorization'];
          final auth = _fromHeader(header);
          if (auth == null) return inner(request);
          return inner(request.change(context: {
            'userId': auth.userId,
            'householdId': auth.householdId,
          }));
        };
      };

  ({String userId, String householdId})? _fromHeader(String? header) {
    if (header == null || !header.toLowerCase().startsWith('bearer ')) {
      return null;
    }
    return tokens.verify(header.substring(7).trim());
  }

  ({String userId, String householdId})? _auth(Request request) {
    final userId = request.context['userId'] as String?;
    final householdId = request.context['householdId'] as String?;
    if (userId == null || householdId == null) return null;
    return (userId: userId, householdId: householdId);
  }

  Future<Map<String, dynamic>> _body(Request request) async {
    final raw = await request.readAsString();
    if (raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  bool _blank(String? value) => value == null || value.isEmpty;

  Response _json(Object data) => Response.ok(
        jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  Response _error(int status, String message) => Response(
        status,
        body: jsonEncode({'error': message}),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}

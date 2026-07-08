import 'dart:convert';
import 'dart:io';

import 'package:home_sweet_home_server/src/api.dart';
import 'package:home_sweet_home_server/src/db.dart';
import 'package:home_sweet_home_server/src/file_store.dart';
import 'package:home_sweet_home_server/src/realtime.dart';
import 'package:home_sweet_home_server/src/tokens.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Api api;
  late Directory filesDir;

  setUp(() async {
    filesDir = await Directory.systemTemp.createTemp('hsh_files_test');
    api = Api(
      db: Db(sqlite3.openInMemory()),
      tokens: Tokens('test-secret'),
      hub: RealtimeHub(),
      files: FileStore(filesDir.path),
    );
  });

  tearDown(() async {
    if (filesDir.existsSync()) await filesDir.delete(recursive: true);
  });

  Future<Map<String, dynamic>> call(
    String method,
    String path, {
    Object? body,
    String? token,
  }) async {
    final headers = {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
    final request = Request(
      method,
      Uri.parse('http://localhost$path'),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
    final response = await api.handler(request);
    final raw = await response.readAsString();
    return {
      'status': response.statusCode,
      'body': raw.isEmpty ? {} : jsonDecode(raw),
    };
  }

  Future<Map<String, dynamic>> register(String email, String name,
          {String? joinCode}) =>
      call('POST', '/auth/register', body: {
        'email': email,
        'password': 'secret1',
        'displayName': name,
        if (joinCode != null) 'joinCode': joinCode,
      });

  test('register crée une maison + session', () async {
    final res = await register('a@test.fr', 'Alice');
    expect(res['status'], 200);
    final body = res['body'] as Map<String, dynamic>;
    expect(body['token'], isA<String>());
    expect(body['user']['displayName'], 'Alice');
    expect(body['household']['members'], hasLength(1));
    expect(body['household']['joinCode'], isA<String>());
  });

  test('email en double → 409', () async {
    await register('a@test.fr', 'Alice');
    final res = await register('a@test.fr', 'Autre');
    expect(res['status'], 409);
  });

  test('mot de passe trop court → 400', () async {
    final res = await call('POST', '/auth/register',
        body: {'email': 'x@test.fr', 'password': '123', 'displayName': 'X'});
    expect(res['status'], 400);
  });

  test('login mauvais mot de passe → 401', () async {
    await register('a@test.fr', 'Alice');
    final res = await call('POST', '/auth/login',
        body: {'email': 'a@test.fr', 'password': 'faux'});
    expect(res['status'], 401);
  });

  test('rejoindre par code → même maison, 2 membres', () async {
    final a = await register('a@test.fr', 'Alice');
    final code = a['body']['household']['joinCode'] as String;
    final b = await register('b@test.fr', 'Bob', joinCode: code);
    expect(b['status'], 200);
    expect(b['body']['household']['id'], a['body']['household']['id']);
    expect(b['body']['household']['members'], hasLength(2));
  });

  test('code de maison invalide → 400', () async {
    final res = await register('a@test.fr', 'Alice', joinCode: 'ZZZZZZ');
    expect(res['status'], 400);
  });

  test('shopping : défaut vide, PUT puis GET persiste', () async {
    final a = await register('a@test.fr', 'Alice');
    final token = a['body']['token'] as String;

    final empty = await call('GET', '/shopping', token: token);
    expect(empty['status'], 200);
    expect(empty['body']['categories'], isEmpty);

    await call('PUT', '/shopping', token: token, body: {
      'householdId': 'ignoré',
      'categories': [
        {'id': 'c1', 'name': 'Frais', 'items': <dynamic>[]},
      ],
    });
    final got = await call('GET', '/shopping', token: token);
    expect(got['body']['categories'], hasLength(1));
    expect(got['body']['categories'][0]['name'], 'Frais');
    // Le serveur fait autorité sur la maison, pas le client.
    expect(got['body']['householdId'], a['body']['household']['id']);
  });

  test('shopping sans token → 401', () async {
    final res = await call('GET', '/shopping');
    expect(res['status'], 401);
  });

  Future<({int status, List<int> bytes, Map<String, dynamic> json})> raw(
    String method,
    String path, {
    List<int>? body,
    String? token,
  }) async {
    final request = Request(
      method,
      Uri.parse('http://localhost$path'),
      headers: {if (token != null) 'authorization': 'Bearer $token'},
      body: body,
    );
    final response = await api.handler(request);
    final bytes = <int>[];
    await for (final chunk in response.read()) {
      bytes.addAll(chunk);
    }
    Map<String, dynamic> json = {};
    if ((response.headers['content-type'] ?? '').contains('json') &&
        bytes.isNotEmpty) {
      json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    }
    return (status: response.statusCode, bytes: bytes, json: json);
  }

  test('upload puis download d\'un fichier document', () async {
    final a = await register('a@test.fr', 'Alice');
    final token = a['body']['token'] as String;
    final image = [137, 80, 78, 71, 1, 2, 3]; // pseudo-PNG

    final up = await raw('POST', '/documents/files?ext=png',
        body: image, token: token);
    expect(up.status, 200);
    final fileId = up.json['fileId'] as String;
    expect(fileId, endsWith('.png'));

    final down = await raw('GET', '/documents/files/$fileId', token: token);
    expect(down.status, 200);
    expect(down.bytes, image);
  });

  test('download d\'un fichier d\'une autre maison → 404', () async {
    final a = await register('a@test.fr', 'Alice');
    final other = await register('x@test.fr', 'Autre'); // autre maison
    final up = await raw('POST', '/documents/files?ext=jpg',
        body: [1, 2, 3], token: a['body']['token'] as String);
    final fileId = up.json['fileId'] as String;

    final res = await raw('GET', '/documents/files/$fileId',
        token: other['body']['token'] as String);
    expect(res.status, 404);
  });

  test('upload extension interdite → 400', () async {
    final a = await register('a@test.fr', 'Alice');
    final res = await raw('POST', '/documents/files?ext=exe',
        body: [1, 2, 3], token: a['body']['token'] as String);
    expect(res.status, 400);
  });

  test('documents : défaut vide', () async {
    final a = await register('a@test.fr', 'Alice');
    final res =
        await call('GET', '/documents', token: a['body']['token'] as String);
    expect(res['status'], 200);
    expect(res['body']['tabs'], isEmpty);
  });
}

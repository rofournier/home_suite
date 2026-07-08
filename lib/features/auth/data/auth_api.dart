import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/auth_repository.dart';

/// Client HTTP bas niveau du serveur d'auth. Traduit les erreurs réseau/HTTP
/// en [AuthException] avec un message affichable.
class AuthApi {
  AuthApi({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    String? joinCode,
  }) =>
      _post('/auth/register', {
        'email': email,
        'password': password,
        'displayName': displayName,
        if (joinCode != null && joinCode.isNotEmpty) 'joinCode': joinCode,
      });

  /// Récupère la session courante à partir d'un jeton (restauration).
  /// Timeout court : au démarrage, ne pas bloquer le splash hors ligne.
  Future<Map<String, dynamic>> me(String token) async {
    final response = await _send(
      () => _client.get(
        _uri('/auth/me'),
        headers: {'authorization': 'Bearer $token'},
      ),
      timeout: const Duration(seconds: 5),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await _send(() => _client.post(
          _uri(path),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(body),
        ));
    return _decode(response);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Timeout : sinon un pare-feu qui « drop » les paquets fait pendre la
      // requête indéfiniment (chargement infini). On échoue vite et lisible.
      return await request().timeout(timeout);
    } catch (_) {
      throw const AuthNetworkException(
          'Serveur injoignable. Vérifie le Wi-Fi et le pare-feu (port 8080).');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final json = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw AuthException(json['error'] as String? ?? 'Erreur serveur');
    }
    return json;
  }
}

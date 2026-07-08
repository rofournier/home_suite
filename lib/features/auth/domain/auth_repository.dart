import 'session.dart';

/// Erreur d'authentification portant un message affichable à l'utilisateur.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Serveur injoignable (offline, timeout) — à distinguer d'un refus explicite :
/// hors ligne on garde la session en cache, on ne déconnecte pas.
class AuthNetworkException extends AuthException {
  const AuthNetworkException(super.message);
}

/// Accès à l'authentification (offline-first : le jeton est persisté localement,
/// la session est restaurée sans re-saisie). L'UI ne parle jamais à l'API en
/// direct → toujours via cette interface.
abstract interface class AuthRepository {
  /// Restaure la session depuis le jeton stocké, ou `null` si absent/expiré.
  Future<Session?> restore();

  Future<Session> login({required String email, required String password});

  /// Inscription. [joinCode] (optionnel) = rejoindre une maison existante.
  Future<Session> register({
    required String email,
    required String password,
    required String displayName,
    String? joinCode,
  });

  Future<void> logout();
}

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Émission / vérification des JWT (HS256). Le token porte l'id user + la
/// maison, ce qui évite un lookup à chaque requête protégée.
class Tokens {
  Tokens(this._secret);

  final String _secret;

  String issue({required String userId, required String householdId}) {
    final jwt = JWT({'hh': householdId}, subject: userId);
    return jwt.sign(SecretKey(_secret), expiresIn: const Duration(days: 30));
  }

  /// Renvoie (userId, householdId) si le token est valide, sinon null.
  ({String userId, String householdId})? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      final payload = jwt.payload as Map<String, dynamic>;
      final userId = jwt.subject;
      final householdId = payload['hh'] as String?;
      if (userId == null || householdId == null) return null;
      return (userId: userId, householdId: householdId);
    } on JWTException {
      return null;
    }
  }
}

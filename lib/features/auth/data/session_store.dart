import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/session.dart';

/// Cache local de la session (jeton + user + maison) pour le démarrage hors
/// ligne. Interface → testable ; impl sur le Keystore Android.
abstract interface class SessionStore {
  /// Valeur brute stockée : JSON de session, ou **jeton nu hérité** des
  /// versions précédentes (avant le cache de session). `null` si déconnecté.
  Future<String?> readRaw();
  Future<void> write(Session session);
  Future<void> clear();
}

/// Décode la valeur brute en session, ou `null` si c'est un jeton nu/illisible.
Session? decodeStoredSession(String raw) {
  if (!raw.startsWith('{')) return null;
  try {
    return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}

class SecureSessionStore implements SessionStore {
  const SecureSessionStore(this._storage);

  final FlutterSecureStorage _storage;
  // Même clé que l'ancien stockage jeton-seul → migration douce.
  static const _key = 'hsh_access_token';

  @override
  Future<String?> readRaw() => _storage.read(key: _key);

  @override
  Future<void> write(Session session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

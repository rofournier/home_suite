import '../domain/auth_repository.dart';
import '../domain/session.dart';
import 'auth_api.dart';
import 'session_store.dart';

/// Impl de [AuthRepository] : API HTTP + cache local de session.
/// Offline-first : déjà connecté → l'app démarre sur la session en cache si le
/// serveur est injoignable ; on ne déconnecte que sur refus explicite (401).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.api, required this.store});

  final AuthApi api;
  final SessionStore store;

  @override
  Future<Session?> restore() async {
    final raw = await store.readRaw();
    if (raw == null) return null;
    final cached = decodeStoredSession(raw);
    // Jeton nu hérité (pas de cache) : raw est le jeton lui-même.
    final token = cached?.token ?? raw;
    try {
      final json = await api.me(token);
      final session = Session.fromJson({...json, 'token': token});
      await store.write(session); // rafraîchit le cache (membres à jour)
      return session;
    } on AuthNetworkException {
      // Hors ligne : on démarre sur le cache (null si jeton nu hérité).
      return cached;
    } on AuthException {
      // Jeton refusé par le serveur : vraie déconnexion.
      await store.clear();
      return null;
    }
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final json = await api.login(email, password);
    return _persist(json);
  }

  @override
  Future<Session> register({
    required String email,
    required String password,
    required String displayName,
    String? joinCode,
  }) async {
    final json = await api.register(
      email: email,
      password: password,
      displayName: displayName,
      joinCode: joinCode,
    );
    return _persist(json);
  }

  @override
  Future<void> logout() => store.clear();

  Future<Session> _persist(Map<String, dynamic> json) async {
    final session = Session.fromJson(json);
    await store.write(session);
    return session;
  }
}

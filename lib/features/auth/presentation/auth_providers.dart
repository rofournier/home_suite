import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_config.dart';
import '../data/auth_api.dart';
import '../data/auth_repository_impl.dart';
import '../data/session_store.dart';
import '../domain/auth_repository.dart';
import '../domain/session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: AuthApi(baseUrl: AppConfig.serverBaseUrl),
    store: const SecureSessionStore(FlutterSecureStorage()),
  );
});

/// Session courante. `null` = déconnecté. `loading` pendant la restauration au
/// démarrage et pendant login/register (le gate route en conséquence).
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

class SessionController extends AsyncNotifier<Session?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<Session?> build() => _repo.restore();

  Future<void> login(String email, String password) =>
      _run(() => _repo.login(email: email, password: password));

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? joinCode,
  }) =>
      _run(() => _repo.register(
            email: email,
            password: password,
            displayName: displayName,
            joinCode: joinCode,
          ));

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  /// Exécute une action d'auth en gérant loading/erreur ; relance l'exception
  /// pour que l'écran affiche le message.
  Future<void> _run(Future<Session> Function() action) async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await action());
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

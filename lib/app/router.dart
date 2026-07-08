import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/documents/presentation/documents_screen.dart';
import '../features/gallery/presentation/gallery_screen.dart';
import '../features/garden/presentation/garden_screen.dart';
import '../features/hub/presentation/hub_screen.dart';
import '../features/paint/presentation/paint_screen.dart';
import '../features/placeholder/presentation/under_construction_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shopping/presentation/shopping_screen.dart';
import '../features/tasks/presentation/plan_screen.dart';
import 'destinations.dart';

/// Destinations déjà dotées d'un vrai écran (les autres → placeholder en V1).
const _implemented = {
  AppDestination.settings,
  AppDestination.shopping,
  AppDestination.documents,
  AppDestination.housePlan,
  AppDestination.paint,
  AppDestination.gallery,
  AppDestination.garden,
};

const _login = '/login';
const _splash = '/splash';

/// Router centralisé + gate d'authentification : pas de hub sans session.
/// Recalcule ses redirections quand la session change.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: _login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, _) => const HubScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/shopping', builder: (_, _) => const ShoppingScreen()),
      GoRoute(path: '/documents', builder: (_, _) => const DocumentsScreen()),
      GoRoute(path: '/house-plan', builder: (_, _) => const PlanScreen()),
      GoRoute(path: '/paint', builder: (_, _) => const PaintScreen()),
      GoRoute(path: '/gallery', builder: (_, _) => const GalleryScreen()),
      GoRoute(path: '/garden', builder: (_, _) => const GardenScreen()),
      for (final destination in AppDestination.values)
        if (!_implemented.contains(destination))
          GoRoute(
            path: destination.route,
            builder: (_, _) =>
                UnderConstructionScreen(destination: destination),
          ),
    ],
  );
});

/// Redirige selon l'état de session : splash tant qu'on restaure, login si
/// déconnecté, hub si connecté.
String? _redirect(Ref ref, GoRouterState state) {
  final session = ref.read(sessionControllerProvider);
  final location = state.matchedLocation;
  final loggedIn = session.asData?.value != null;
  if (loggedIn) {
    // Connecté : quitter les écrans d'accueil vers le hub.
    return (location == _login || location == _splash) ? '/' : null;
  }
  // Restauration initiale (chargement sans valeur connue) → splash. Mais si
  // l'utilisateur agit déjà depuis le login (inscription/connexion en cours),
  // on reste sur le login (bouton en attente) au lieu de basculer au splash.
  if (session.isLoading && !session.hasValue && location != _login) {
    return location == _splash ? null : _splash;
  }
  // Déconnecté (données ou erreur) → login.
  return location == _login ? null : _login;
}

/// Ponte Riverpod → Listenable : notifie go_router à chaque changement de
/// session pour qu'il réévalue les redirections.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    _sub = ref.listen(
      sessionControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

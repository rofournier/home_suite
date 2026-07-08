import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/persistence/shared_preferences_provider.dart';
import '../../household/presentation/household_providers.dart';
import '../data/shopping_events.dart';
import '../data/shopping_local_datasource.dart';
import '../data/shopping_repository_impl.dart';
import '../domain/shopping_list.dart';
import '../domain/shopping_repository.dart';

final _datasourceProvider = Provider<ShoppingLocalDatasource>(
  (ref) => ShoppingLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

/// Ouvre la connexion temps réel de la maison. Le cycle de vie du service
/// (déconnexion) appartient à [realtimeServiceProvider] : ici on ne fait
/// qu'établir la connexion tant qu'un écran l'observe.
final realtimeConnectionProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(realtimeServiceProvider);
  final household = ref.watch(householdProvider);
  await service.connect(household.id);
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  final repository = ShoppingRepositoryImpl(
    datasource: ref.watch(_datasourceProvider),
    realtime: ref.watch(realtimeServiceProvider),
    household: ref.watch(householdProvider),
    currentMember: ref.watch(currentMemberProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Liste courante (onglets + articles). État async : loading / error / data.
final shoppingListProvider = StreamProvider<ShoppingList>(
  (ref) => ref.watch(shoppingRepositoryProvider).watch(),
);

/// Applique les états reçus des autres membres (temps réel) sur le repo local,
/// et re-publie le local à chaque (re)connexion (réconciliation hors ligne).
/// Doit être observé (hub + écran courses) pour rester actif.
final shoppingSyncProvider = Provider<void>((ref) {
  final repository = ref.watch(shoppingRepositoryProvider);
  final realtime = ref.watch(realtimeServiceProvider);
  final events = realtime.events.listen((event) {
    if (event.type != ShoppingEvents.sync) return;
    final list = event.payload?['list'];
    if (list is Map<String, dynamic>) {
      repository.applyRemote(ShoppingList.fromJson(list));
    }
  });
  final connects = realtime.onConnect.listen((_) => repository.republish());
  ref.onDispose(() {
    events.cancel();
    connects.cancel();
  });
});

/// Id de l'onglet actif. `null` = pas encore choisi → défaut sur le premier.
final activeCategoryProvider = NotifierProvider<ActiveCategoryNotifier, String?>(
    ActiveCategoryNotifier.new);

class ActiveCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String categoryId) => state = categoryId;
}

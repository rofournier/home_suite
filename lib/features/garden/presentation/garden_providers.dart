import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/files/local_image_store.dart';
import '../../../core/persistence/shared_preferences_provider.dart';
import '../../documents/presentation/document_providers.dart'
    show documentRemoteProvider;
import '../../household/presentation/household_providers.dart';
import '../data/garden_events.dart';
import '../data/garden_local_datasource.dart';
import '../data/garden_repository_impl.dart';
import '../domain/garden.dart';
import '../domain/garden_repository.dart';
import '../domain/watering_status.dart';

final _datasourceProvider = Provider<GardenLocalDatasource>(
  (ref) => GardenLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

final _imageStoreProvider =
    Provider<LocalImageStore>((ref) => LocalImageStore(subdir: 'garden'));

final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  final repository = GardenRepositoryImpl(
    datasource: ref.watch(_datasourceProvider),
    imageStore: ref.watch(_imageStoreProvider),
    realtime: ref.watch(realtimeServiceProvider),
    household: ref.watch(householdProvider),
    currentMember: ref.watch(currentMemberProvider),
    remote: ref.watch(documentRemoteProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Jardin courant. Loading / error / data.
final gardenProvider = StreamProvider<Garden>(
  (ref) => ref.watch(gardenRepositoryProvider).watch(),
);

/// Applique les états reçus des autres membres et re-publie le local à chaque
/// (re)connexion. Observé par le hub + l'écran jardin.
final gardenSyncProvider = Provider<void>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  final realtime = ref.watch(realtimeServiceProvider);
  final events = realtime.events.listen((event) {
    if (event.type != GardenEvents.sync) return;
    final garden = event.payload?['garden'];
    if (garden is Map<String, dynamic>) {
      repository.applyRemote(Garden.fromJson(garden));
    }
  });
  final connects = realtime.onConnect.listen((_) => repository.republish());
  ref.onDispose(() {
    events.cancel();
    connects.cancel();
  });
});

/// Nombre de plantes ayant un besoin immédiat (eau **ou** engrais) — badge du
/// hotspot Jardin sur le hub. C'est un état (recalculé à chaque évolution du
/// jardin), pas un compteur d'évènements : pas de « vu/non-vu ».
final hubGardenDueProvider = Provider<int>((ref) {
  final garden = ref.watch(gardenProvider).asData?.value;
  if (garden == null) return 0;
  final now = DateTime.now();
  return garden.plants.where((p) => needsCare(p, now)).length;
});

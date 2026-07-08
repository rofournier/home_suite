import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/files/local_image_store.dart';
import '../../../core/persistence/shared_preferences_provider.dart';
import '../../documents/presentation/document_providers.dart'
    show documentRemoteProvider;
import '../../household/presentation/household_providers.dart';
import '../data/gallery_events.dart';
import '../data/gallery_local_datasource.dart';
import '../data/gallery_repository_impl.dart';
import '../domain/gallery_album.dart';
import '../domain/gallery_repository.dart';

final _datasourceProvider = Provider<GalleryLocalDatasource>(
  (ref) => GalleryLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

final _imageStoreProvider =
    Provider<LocalImageStore>((ref) => LocalImageStore(subdir: 'gallery'));

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final repository = GalleryRepositoryImpl(
    datasource: ref.watch(_datasourceProvider),
    imageStore: ref.watch(_imageStoreProvider),
    realtime: ref.watch(realtimeServiceProvider),
    household: ref.watch(householdProvider),
    currentMember: ref.watch(currentMemberProvider),
    // Le client binaires est générique (upload/download par maison).
    remote: ref.watch(documentRemoteProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Album courant (dessins). Loading / error / data.
final galleryAlbumProvider = StreamProvider<GalleryAlbum>(
  (ref) => ref.watch(galleryRepositoryProvider).watch(),
);

/// Applique les états reçus des autres membres et re-publie le local à chaque
/// (re)connexion. Observé par le hub + les écrans galerie/dessin.
final gallerySyncProvider = Provider<void>((ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  final realtime = ref.watch(realtimeServiceProvider);
  final events = realtime.events.listen((event) {
    if (event.type != GalleryEvents.sync) return;
    final album = event.payload?['album'];
    if (album is Map<String, dynamic>) {
      repository.applyRemote(GalleryAlbum.fromJson(album));
    }
  });
  final connects = realtime.onConnect.listen((_) => repository.republish());
  ref.onDispose(() {
    events.cancel();
    connects.cancel();
  });
});

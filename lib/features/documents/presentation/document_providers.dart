import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/config/app_config.dart';
import '../../../core/persistence/shared_preferences_provider.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../household/presentation/household_providers.dart';
import '../data/document_events.dart';
import '../../../core/files/local_image_store.dart';
import '../data/document_local_datasource.dart';
import '../data/document_remote_datasource.dart';
import '../data/document_repository_impl.dart';
import '../domain/document_library.dart';
import '../domain/document_repository.dart';
import '../domain/document_sort.dart';

final _datasourceProvider = Provider<DocumentLocalDatasource>(
  (ref) => DocumentLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

final _imageStoreProvider =
    Provider<LocalImageStore>((ref) => LocalImageStore(subdir: 'documents'));

/// Client binaires : présent seulement avec une session (token requis).
final documentRemoteProvider = Provider<DocumentRemoteDatasource?>((ref) {
  final token = ref.watch(sessionControllerProvider).asData?.value?.token;
  if (token == null) return null;
  return DocumentRemoteDatasource(
      baseUrl: AppConfig.serverBaseUrl, token: token);
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final repository = DocumentRepositoryImpl(
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

/// Applique les états reçus des autres membres (temps réel) sur le repo local,
/// et re-publie le local à chaque (re)connexion (réconciliation hors ligne).
final documentSyncProvider = Provider<void>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final realtime = ref.watch(realtimeServiceProvider);
  final events = realtime.events.listen((event) {
    if (event.type != DocumentEvents.sync) return;
    final library = event.payload?['library'];
    if (library is Map<String, dynamic>) {
      repository.applyRemote(DocumentLibrary.fromJson(library));
    }
  });
  final connects = realtime.onConnect.listen((_) => repository.republish());
  ref.onDispose(() {
    events.cancel();
    connects.cancel();
  });
});

/// Bibliothèque courante (onglets + documents). Loading / error / data.
final documentLibraryProvider = StreamProvider<DocumentLibrary>(
  (ref) => ref.watch(documentRepositoryProvider).watch(),
);

/// Onglet actif. `null` = défaut sur le premier.
final activeDocTabProvider =
    NotifierProvider<ActiveDocTabNotifier, String?>(ActiveDocTabNotifier.new);

class ActiveDocTabNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String tabId) => state = tabId;
}

/// Tri courant (partagé par les onglets). Défaut : date décroissante.
final documentSortProvider =
    NotifierProvider<DocumentSortNotifier, DocumentSort>(
        DocumentSortNotifier.new);

class DocumentSortNotifier extends Notifier<DocumentSort> {
  @override
  DocumentSort build() => const DocumentSort();
  void setField(DocSortField field) => state = state.withField(field);
  void toggleOrder() => state = state.toggleOrder();
}

import 'document.dart';
import 'document_library.dart';

/// Accès aux documents d'une maison. Local = source de vérité (offline-first) ;
/// l'impl publie chaque mutation sur le `RealtimeService` (server-ready). Les
/// fichiers images vivent sur disque ; seules les métadonnées sont synchronisées
/// en V1 (l'upload des binaires viendra en ajout).
///
/// Scopée à une maison au chargement.
abstract interface class DocumentRepository {
  Stream<DocumentLibrary> watch();

  Future<String> addTab(String name);
  Future<void> renameTab(String tabId, String name);
  Future<void> deleteTab(String tabId);
  Future<void> reorderTabs(List<String> orderedIds);

  /// Copie l'image [sourcePath] (photo prise/choisie) dans le stockage local
  /// de l'app puis crée le document. Renvoie le document créé.
  Future<Document> addDocument(
    String tabId, {
    required String sourcePath,
    required String title,
  });

  Future<void> renameDocument(String tabId, String docId, String title);
  Future<void> deleteDocument(String tabId, String docId);

  /// Applique un état reçu d'un autre membre (temps réel), sans re-publier.
  /// Ignoré si l'état entrant est plus vieux que le local (LWW).
  Future<void> applyRemote(DocumentLibrary library);

  /// Re-publie l'état local (réconciliation à la (re)connexion temps réel).
  Future<void> republish();
}

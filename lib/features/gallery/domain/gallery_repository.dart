import 'gallery_album.dart';
import 'gallery_item.dart';

/// Accès à la galerie de dessins d'une maison. Local = source de vérité ;
/// binaires uploadés best-effort, métadonnées synchronisées en temps réel.
abstract interface class GalleryRepository {
  Stream<GalleryAlbum> watch();

  /// Enregistre un dessin (fichier PNG rendu par l'app Paint) dans la galerie.
  Future<GalleryItem> addDrawing({
    required String sourcePath,
    required String title,
  });

  Future<void> deleteItem(String itemId);

  /// Applique un état reçu (temps réel). Ignoré si plus vieux (LWW).
  Future<void> applyRemote(GalleryAlbum album);

  /// Re-publie l'état local (réconciliation à la (re)connexion).
  Future<void> republish();
}

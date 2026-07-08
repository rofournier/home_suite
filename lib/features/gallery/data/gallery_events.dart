import '../../../core/realtime/realtime_service.dart';

/// Évènements temps réel de la galerie. La sync porte les métadonnées
/// complètes (`payload['album']`) ; les binaires transitent par HTTP.
abstract final class GalleryEvents {
  static const sync = 'gallery.sync';
}

RealtimeEvent gallerySyncEvent(Map<String, dynamic> albumJson) =>
    RealtimeEvent(type: GalleryEvents.sync, payload: {'album': albumJson});

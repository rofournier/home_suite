import '../../../core/realtime/realtime_service.dart';

/// Types d'évènements temps réel des documents. La sync porte les métadonnées
/// complètes (`payload['library']`) ; les binaires transitent par HTTP
/// (upload/download `fileId`), pas par le WebSocket.
abstract final class DocumentEvents {
  static const sync = 'document.sync';
}

RealtimeEvent documentSyncEvent(Map<String, dynamic> libraryJson) =>
    RealtimeEvent(
      type: DocumentEvents.sync,
      payload: {'library': libraryJson},
    );

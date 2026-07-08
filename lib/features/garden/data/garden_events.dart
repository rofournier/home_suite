import '../../../core/realtime/realtime_service.dart';

/// Évènements temps réel du jardin. La sync porte l'état complet
/// (`payload['garden']`) ; les photos transitent par HTTP.
abstract final class GardenEvents {
  static const sync = 'garden.sync';
}

RealtimeEvent gardenSyncEvent(Map<String, dynamic> gardenJson) =>
    RealtimeEvent(type: GardenEvents.sync, payload: {'garden': gardenJson});

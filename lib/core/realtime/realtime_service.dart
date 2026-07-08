/// Un évènement temps réel échangé entre les membres d'une maison.
class RealtimeEvent {
  const RealtimeEvent({required this.type, this.payload});

  final String type;
  final Map<String, dynamic>? payload;
}

/// Abstraction du temps réel (plusieurs users par maison via sockets).
///
/// V1 : implémentation no-op. L'impl WebSocket viendra plus tard sans
/// toucher l'UI — aucune logique socket ne doit vivre dans les widgets.
abstract interface class RealtimeService {
  Stream<RealtimeEvent> get events;

  /// Émet après chaque (re)connexion réussie. Les repos y re-publient leur
  /// état local (réconciliation après une période hors ligne).
  Stream<void> get onConnect;

  Future<void> connect(String householdId);
  Future<void> publish(RealtimeEvent event);
  Future<void> disconnect();
}

class NoopRealtimeService implements RealtimeService {
  @override
  Stream<RealtimeEvent> get events => const Stream.empty();

  @override
  Stream<void> get onConnect => const Stream.empty();

  @override
  Future<void> connect(String householdId) async {}

  @override
  Future<void> publish(RealtimeEvent event) async {}

  @override
  Future<void> disconnect() async {}
}

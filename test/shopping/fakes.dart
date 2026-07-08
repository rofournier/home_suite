import 'dart:async';

import 'package:home_sweet_home/core/realtime/realtime_service.dart';
import 'package:home_sweet_home/features/shopping/data/shopping_repository_impl.dart';

/// `RealtimeService` contrôlable : capture les publications, permet d'injecter
/// des évènements entrants.
class FakeRealtimeService implements RealtimeService {
  final _controller = StreamController<RealtimeEvent>.broadcast();
  final _connects = StreamController<void>.broadcast();
  final published = <RealtimeEvent>[];

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  @override
  Stream<void> get onConnect => _connects.stream;

  @override
  Future<void> connect(String householdId) async {}

  @override
  Future<void> publish(RealtimeEvent event) async => published.add(event);

  @override
  Future<void> disconnect() async {}

  void emit(RealtimeEvent event) => _controller.add(event);

  /// Simule une (re)connexion réussie.
  void emitConnected() => _connects.add(null);

  void dispose() {
    _controller.close();
    _connects.close();
  }
}

/// Générateur d'ids déterministe pour les tests (id0, id1, …).
class SeqIdGenerator extends IdGenerator {
  int _n = 0;
  @override
  String next() => 'id${_n++}';
}

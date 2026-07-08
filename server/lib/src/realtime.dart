import 'package:web_socket_channel/web_socket_channel.dart';

/// Salon temps réel : les sinks WebSocket connectés, groupés par maison.
/// Un message publié par un membre est rediffusé aux autres membres de la
/// même maison (jamais à l'émetteur).
class RealtimeHub {
  final Map<String, Set<WebSocketChannel>> _rooms = {};

  void join(String householdId, WebSocketChannel channel) =>
      _rooms.putIfAbsent(householdId, () => {}).add(channel);

  void leave(String householdId, WebSocketChannel channel) {
    final room = _rooms[householdId];
    if (room == null) return;
    room.remove(channel);
    if (room.isEmpty) _rooms.remove(householdId);
  }

  /// Rediffuse [message] aux membres de la maison, en excluant [from].
  void broadcast(String householdId, String message, WebSocketChannel from) {
    final room = _rooms[householdId];
    if (room == null) return;
    for (final channel in room) {
      if (channel == from) continue;
      channel.sink.add(message);
    }
  }
}

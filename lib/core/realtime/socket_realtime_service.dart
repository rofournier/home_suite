import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import 'realtime_service.dart';

/// Impl WebSocket de [RealtimeService]. Se connecte au serveur local, émet les
/// évènements entrants et publie les sortants. Offline-first : un échec de
/// connexion ne casse rien (l'app reste utilisable), et on retente en fond.
class SocketRealtimeService implements RealtimeService {
  SocketRealtimeService(this._token);

  final String _token;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  final _connectController = StreamController<void>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _retry;
  bool _closed = false;
  int _attempt = 0;

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  @override
  Stream<void> get onConnect => _connectController.stream;

  @override
  Future<void> connect(String householdId) async {
    _closed = false;
    await _open();
  }

  Future<void> _open() async {
    if (_closed) return;
    try {
      final channel = WebSocketChannel.connect(AppConfig.realtimeUri(_token));
      await channel.ready;
      _channel = channel;
      _attempt = 0;
      _sub = channel.stream.listen(
        _onData,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
      _connectController.add(null);
    } catch (_) {
      // Serveur injoignable : on planifie une reconnexion, sans propager.
      _scheduleReconnect();
    }
  }

  /// Backoff plafonné : 2s, 4s, … max 30s. Silencieux tant que hors ligne.
  void _scheduleReconnect() {
    _channel = null;
    if (_closed || _retry != null) return;
    final seconds = (2 << _attempt.clamp(0, 4)).clamp(2, 30);
    _attempt++;
    _retry = Timer(Duration(seconds: seconds), () {
      _retry = null;
      _open();
    });
  }

  void _onData(dynamic data) {
    if (data is! String) return;
    final decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic>) return;
    final type = decoded['type'];
    if (type is! String) return;
    final payload = decoded['payload'];
    _controller.add(RealtimeEvent(
      type: type,
      payload: payload is Map<String, dynamic> ? payload : null,
    ));
  }

  @override
  Future<void> publish(RealtimeEvent event) async {
    final channel = _channel;
    if (channel == null) return; // hors ligne : le local reste la vérité
    channel.sink.add(jsonEncode({
      'type': event.type,
      if (event.payload != null) 'payload': event.payload,
    }));
  }

  @override
  Future<void> disconnect() async {
    _closed = true;
    _retry?.cancel();
    _retry = null;
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    await _controller.close();
    await _connectController.close();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/realtime/realtime_service.dart';
import '../core/realtime/socket_realtime_service.dart';
import '../features/auth/presentation/auth_providers.dart';

/// Composition (couche app) : choisit l'impl temps réel selon la session.
/// Connecté → WebSocket vers le serveur local ; sinon → no-op. Le core reste
/// ignorant des features ; c'est ici qu'on relie les deux.
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final token = ref.watch(sessionControllerProvider).asData?.value?.token;
  if (token == null) return NoopRealtimeService();
  final service = SocketRealtimeService(token);
  ref.onDispose(service.disconnect);
  return service;
});

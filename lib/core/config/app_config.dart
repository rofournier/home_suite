/// Adresse du serveur local. Surchargée au build :
/// `flutter run --dart-define=HSH_SERVER=http://192.168.1.20:8080`.
/// Défaut = loopback hôte de l'émulateur Android (10.0.2.2).
abstract final class AppConfig {
  static const serverBaseUrl = String.fromEnvironment(
    'HSH_SERVER',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// URL WebSocket dérivée du base HTTP (http→ws, https→wss).
  static Uri realtimeUri(String token) {
    final base = Uri.parse(serverBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(scheme: scheme, path: '/realtime', queryParameters: {
      'token': token,
    });
  }
}

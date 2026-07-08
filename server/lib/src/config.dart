import 'dart:io';

/// Configuration serveur, surchargée par variables d'environnement.
/// Le secret JWT DOIT être fixé en prod ; le défaut n'est que pour le dev local.
class ServerConfig {
  ServerConfig({
    required this.port,
    required this.jwtSecret,
    required this.dbPath,
    required this.filesDir,
  });

  final int port;
  final String jwtSecret;
  final String dbPath;

  /// Dossier des binaires uploadés (images de documents).
  final String filesDir;

  factory ServerConfig.fromEnv() {
    final env = Platform.environment;
    return ServerConfig(
      port: int.tryParse(env['HSH_PORT'] ?? '') ?? 8080,
      jwtSecret: env['HSH_JWT_SECRET'] ?? 'dev-secret-change-me',
      dbPath: env['HSH_DB_PATH'] ?? 'home_sweet_home.db',
      filesDir: env['HSH_FILES_DIR'] ?? 'files',
    );
  }
}

import 'dart:io';

import 'package:home_sweet_home_server/src/api.dart';
import 'package:home_sweet_home_server/src/config.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Point d'entrée : `dart run bin/server.dart`. Écoute sur toutes les
/// interfaces pour que le téléphone (même LAN) puisse joindre le serveur.
Future<void> main() async {
  final config = ServerConfig.fromEnv();
  final api = Api.fromConfig(config);
  final server = await io.serve(api.handler, InternetAddress.anyIPv4, config.port);
  stdout.writeln('Home Sweet Home server → http://${server.address.host}:${server.port}');
}

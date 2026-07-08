import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stockage sur disque des images d'une feature ([subdir] : `documents`,
/// `gallery`, …). Copie une image source (temp du picker / rendu de dessin)
/// dans le dossier persistant de l'app, nommée par id. Testable (dossier de
/// base injectable).
class LocalImageStore {
  LocalImageStore({
    required this.subdir,
    Future<Directory> Function()? baseDir,
  }) : _baseDir = baseDir ?? getApplicationDocumentsDirectory;

  final String subdir;
  final Future<Directory> Function() _baseDir;

  Future<Directory> _dir() async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, subdir));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Copie [sourcePath] → dossier persistant, fichier nommé `<id>.<ext>`.
  Future<String> persist({
    required String sourcePath,
    required String id,
  }) async {
    final dir = await _dir();
    final ext = p.extension(sourcePath);
    final dest = p.join(dir.path, '$id$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

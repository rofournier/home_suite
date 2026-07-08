import 'dart:io';

import 'package:uuid/uuid.dart';

/// Stockage disque des binaires uploadés (images), nommés `<uuid>.<ext>`,
/// rangés par maison : `<base>/<householdId>/<fileId>`. L'id de fichier renvoyé
/// au client suffit pour le retrouver (l'appartenance est portée par le chemin).
class FileStore {
  FileStore(this._basePath);

  final String _basePath;
  static const _uuid = Uuid();

  static const _allowedExt = {'jpg', 'jpeg', 'png', 'webp', 'heic'};

  Directory _dir(String householdId) {
    final dir = Directory('$_basePath/$householdId');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Écrit [bytes] et renvoie l'id de fichier (`<uuid>.<ext>`), ou null si
  /// l'extension n'est pas autorisée.
  Future<String?> save(String householdId, String ext, List<int> bytes) async {
    final clean = ext.toLowerCase().replaceAll('.', '');
    if (!_allowedExt.contains(clean)) return null;
    final fileId = '${_uuid.v4()}.$clean';
    await File('${_dir(householdId).path}/$fileId').writeAsBytes(bytes);
    return fileId;
  }

  /// Renvoie le fichier, ou null s'il n'existe pas (ou id malformé).
  File? find(String householdId, String fileId) {
    // Refuse tout id qui tenterait de sortir du dossier de la maison.
    if (fileId.contains('/') || fileId.contains('..')) return null;
    final file = File('${_dir(householdId).path}/$fileId');
    return file.existsSync() ? file : null;
  }

  String contentType(String fileId) {
    final ext = fileId.split('.').last;
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}

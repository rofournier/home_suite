import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Client HTTP des binaires documents. Best-effort : toute erreur (offline,
/// serveur down) renvoie null — le local reste la source de vérité et
/// l'affichage retombe sur la copie locale.
class DocumentRemoteDatasource {
  DocumentRemoteDatasource({
    required this.baseUrl,
    required this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String token;
  final http.Client _client;

  /// Uploade l'image et renvoie son `fileId`, ou null en cas d'échec.
  Future<String?> upload(String imagePath) async {
    try {
      final ext = p.extension(imagePath).replaceAll('.', '');
      final bytes = await File(imagePath).readAsBytes();
      final response = await _client
          .post(
            Uri.parse('$baseUrl/documents/files?ext=$ext'),
            headers: {'authorization': 'Bearer $token'},
            body: bytes,
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['fileId'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// URL de téléchargement d'un binaire (avec les en-têtes [authHeaders]).
  Uri fileUri(String fileId) => Uri.parse('$baseUrl/documents/files/$fileId');

  Map<String, String> get authHeaders => {'authorization': 'Bearer $token'};
}

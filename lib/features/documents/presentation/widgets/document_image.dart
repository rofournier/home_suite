import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/document.dart';
import '../document_providers.dart';

/// Affiche l'image d'un document : copie locale si présente (auteur),
/// sinon téléchargement authentifié via `fileId` (autres membres).
class DocumentImage extends ConsumerWidget {
  const DocumentImage({
    super.key,
    required this.doc,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final Document doc;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (File(doc.imagePath).existsSync()) {
      return Image.file(
        File(doc.imagePath),
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => const _Broken(),
      );
    }
    final remote = ref.watch(documentRemoteProvider);
    final fileId = doc.fileId;
    if (remote == null || fileId == null) return const _Broken();
    return Image.network(
      remote.fileUri(fileId).toString(),
      headers: remote.authHeaders,
      fit: fit,
      cacheWidth: cacheWidth,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, _, _) => const _Broken(),
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken();

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.inkSoft),
      );
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../documents/presentation/document_providers.dart'
    show documentRemoteProvider;
import '../../domain/gallery_item.dart';

/// Affiche un dessin : copie locale si présente (auteur), sinon
/// téléchargement authentifié via `fileId` (autres membres).
class GalleryImage extends ConsumerWidget {
  const GalleryImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final GalleryItem item;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (File(item.imagePath).existsSync()) {
      return Image.file(
        File(item.imagePath),
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => const _Broken(),
      );
    }
    final remote = ref.watch(documentRemoteProvider);
    final fileId = item.fileId;
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

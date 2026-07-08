import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../app/theme_tokens.dart';
import '../../household/presentation/household_providers.dart';
import '../../shopping/presentation/shopping_providers.dart'
    show realtimeConnectionProvider;
import '../domain/gallery_album.dart';
import '../domain/gallery_item.dart';
import 'gallery_providers.dart';
import 'widgets/gallery_image.dart';

/// 🖼️ Galerie — les dessins du foyer, du plus récent au plus ancien.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeConnectionProvider);
    ref.watch(gallerySyncProvider);
    final albumAsync = ref.watch(galleryAlbumProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Galerie'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppDestination.paint.route),
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.onDopamine,
        icon: const Icon(Icons.brush_outlined),
        label: const Text('Dessiner'),
      ),
      body: SafeArea(
        top: false,
        child: albumAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Impossible de charger la galerie')),
          data: (album) => album.items.isEmpty
              ? const _EmptyGallery()
              : _Grid(album: album),
        ),
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.album});

  final GalleryAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: album.items.length,
      itemBuilder: (context, index) {
        final item = album.items[index];
        return _DrawingCard(item: item);
      },
    );
  }
}

class _DrawingCard extends ConsumerWidget {
  const _DrawingCard({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(householdProvider);
    final author = household.members
        .where((m) => m.id == item.createdBy)
        .map((m) => m.displayName)
        .firstOrNull;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _openViewer(context, item),
      onLongPress: () => _menu(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: Container(
                color: AppColors.paper,
                width: double.infinity,
                child: GalleryImage(item: item, cacheWidth: 500),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (author != null)
            Text('par $author',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context, GalleryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(item.title),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: GalleryImage(item: item, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline_rounded,
              color: AppColors.terracotta),
          title: const Text('Supprimer',
              style: TextStyle(color: AppColors.terracotta)),
          onTap: () {
            Navigator.of(sheetContext).pop();
            ref.read(galleryRepositoryProvider).deleteItem(item.id);
          },
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 48, color: AppColors.inkSoft),
          const SizedBox(height: AppSpacing.sm),
          Text('Aucun dessin', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Lance-toi avec le bouton Dessiner !',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

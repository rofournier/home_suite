import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_tokens.dart';
import '../domain/document_library.dart';
import '../domain/document_sort.dart';
import 'document_providers.dart';
import 'widgets/add_document_sheet.dart';
import 'widgets/document_grid.dart';
import 'widgets/document_sort_control.dart';
import 'widgets/document_tabs.dart';
import 'widgets/document_viewer.dart';

/// 📄 Documents — partage de photos organisées en onglets, triables.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(documentSyncProvider); // applique les états reçus des autres
    final libraryAsync = ref.watch(documentLibraryProvider);
    final library = libraryAsync.asData?.value;
    final activeTabId =
        library == null ? null : _effectiveActive(ref, library);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Documents'),
      ),
      floatingActionButton: activeTabId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => addDocumentFlow(context, ref, activeTabId),
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.onDopamine,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Ajouter'),
            ),
      body: SafeArea(
        top: false,
        child: libraryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
              child: Text('Impossible de charger les documents')),
          data: (library) => _Loaded(library: library, activeId: activeTabId!),
        ),
      ),
    );
  }
}

String _effectiveActive(WidgetRef ref, DocumentLibrary library) {
  final selected = ref.watch(activeDocTabProvider);
  final ids = library.tabs.map((t) => t.id).toSet();
  if (selected != null && ids.contains(selected)) return selected;
  return library.tabs.first.id;
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.library, required this.activeId});

  final DocumentLibrary library;
  final String activeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (library.tabs.isEmpty) {
      return const Center(child: Text('Aucun onglet'));
    }
    final tab = library.tabById(activeId) ?? library.tabs.first;
    final sort = ref.watch(documentSortProvider);
    final sorted = sortDocuments(tab.documents, sort);

    return Column(
      children: [
        DocumentTabs(tabs: library.tabs, activeId: tab.id),
        const DocumentSortControl(),
        Expanded(
          child: sorted.isEmpty
              ? const _EmptyTab()
              : DocumentGrid(
                  documents: sorted,
                  onOpen: (doc) => openDocumentViewer(context, doc),
                ),
        ),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_library_outlined,
              size: 48, color: AppColors.inkSoft),
          const SizedBox(height: AppSpacing.sm),
          Text('Aucun document',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Ajoute une photo avec le bouton +',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

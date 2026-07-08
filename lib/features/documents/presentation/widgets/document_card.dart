import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/document.dart';
import '../document_providers.dart';
import 'document_image.dart';
import 'document_tab_dialogs.dart';

/// Vignette d'un document : photo + titre + date. Tap → plein écran ;
/// appui long → menu (renommer / supprimer).
class DocumentCard extends ConsumerWidget {
  const DocumentCard({super.key, required this.doc, required this.onOpen});

  final Document doc;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onOpen,
      onLongPress: () => _menu(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: Container(
                color: AppColors.sand,
                width: double.infinity,
                child: DocumentImage(doc: doc, cacheWidth: 500),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            doc.title.isEmpty ? 'Sans titre' : doc.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            _stamp(doc.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Renommer'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final title = await promptDocumentTitle(context, doc.title);
                if (title != null) {
                  await ref
                      .read(documentRepositoryProvider)
                      .renameDocument(doc.tabId, doc.id, title);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.terracotta),
              title: const Text('Supprimer',
                  style: TextStyle(color: AppColors.terracotta)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(documentRepositoryProvider)
                    .deleteDocument(doc.tabId, doc.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Date courte jj/mm/aaaa (sans dépendance intl).
String _stamp(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

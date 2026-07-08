import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../document_providers.dart';

/// Flux d'ajout : choisit la source (caméra à la volée ou galerie), récupère la
/// photo, puis crée le document dans [tabId]. Robuste aux annulations/erreurs.
Future<void> addDocumentFlow(
  BuildContext context,
  WidgetRef ref,
  String tabId,
) async {
  final source = await _chooseSource(context);
  if (source == null) return;
  try {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2400,
      imageQuality: 88,
    );
    if (file == null) return; // annulé
    await ref.read(documentRepositoryProvider).addDocument(
          tabId,
          sourcePath: file.path,
          title: _defaultTitle(DateTime.now()),
        );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ajouter la photo.')),
      );
    }
  }
}

Future<ImageSource?> _chooseSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

String _defaultTitle(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Document ${two(d.day)}/${two(d.month)}';
}

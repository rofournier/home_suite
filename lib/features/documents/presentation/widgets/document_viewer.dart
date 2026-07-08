import 'package:flutter/material.dart';

import '../../domain/document.dart';
import 'document_image.dart';

/// Ouvre une photo en plein écran (zoom/pan). Route dédiée, fond sombre.
void openDocumentViewer(BuildContext context, Document doc) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _DocumentViewer(doc: doc),
    ),
  );
}

class _DocumentViewer extends StatelessWidget {
  const _DocumentViewer({required this.doc});

  final Document doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(doc.title.isEmpty ? 'Document' : doc.title),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: DocumentImage(doc: doc, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

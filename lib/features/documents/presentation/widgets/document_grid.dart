import 'package:flutter/material.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/document.dart';
import 'document_card.dart';

/// Grille de documents où chaque carte est positionnée en absolu et **glisse**
/// vers sa nouvelle case quand l'ordre change (tri) → animation satisfaisante.
/// Chaque carte est keyée par id : Flutter conserve l'élément et anime son
/// déplacement plutôt que de le reconstruire. Respecte reduced-motion.
class DocumentGrid extends StatelessWidget {
  const DocumentGrid({
    super.key,
    required this.documents,
    required this.onOpen,
  });

  final List<Document> documents;
  final void Function(Document doc) onOpen;

  static const _spacing = AppSpacing.md;
  static const _cellAspect = 0.82; // largeur / hauteur d'une case

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / 200).floor().clamp(2, 4);
        final cellWidth = (width - _spacing * (columns - 1)) / columns;
        final cellHeight = cellWidth / _cellAspect;
        final rows = (documents.length / columns).ceil();
        final totalHeight = rows == 0
            ? 0.0
            : rows * cellHeight + (rows - 1) * _spacing;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            height: totalHeight,
            width: width,
            child: Stack(
              children: [
                for (var i = 0; i < documents.length; i++)
                  _slot(
                    doc: documents[i],
                    index: i,
                    columns: columns,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                    reduceMotion: reduceMotion,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slot({
    required Document doc,
    required int index,
    required int columns,
    required double cellWidth,
    required double cellHeight,
    required bool reduceMotion,
  }) {
    final col = index % columns;
    final row = index ~/ columns;
    return AnimatedPositioned(
      key: ValueKey(doc.id),
      duration: Duration(milliseconds: reduceMotion ? 0 : 320),
      curve: Curves.easeOutCubic,
      left: col * (cellWidth + _spacing),
      top: row * (cellHeight + _spacing),
      width: cellWidth,
      height: cellHeight,
      child: DocumentCard(doc: doc, onOpen: () => onOpen(doc)),
    );
  }
}

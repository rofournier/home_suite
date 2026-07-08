import 'package:freezed_annotation/freezed_annotation.dart';

import 'document.dart';

part 'document_tab.freezed.dart';
part 'document_tab.g.dart';

/// Un onglet de documents (ex. « Factures »). Porte ses photos. Transformations
/// pures (immuables, ids/dates injectés) → testables unitairement.
@freezed
abstract class DocumentTab with _$DocumentTab {
  const factory DocumentTab({
    required String id,
    required String name,
    @Default(<Document>[]) List<Document> documents,
  }) = _DocumentTab;
  const DocumentTab._();

  factory DocumentTab.fromJson(Map<String, dynamic> json) =>
      _$DocumentTabFromJson(json);

  int _indexOf(String docId) => documents.indexWhere((d) => d.id == docId);

  DocumentTab addDocument(Document doc) =>
      copyWith(documents: [...documents, doc]);

  DocumentTab renameDocument(String docId, String title) {
    final i = _indexOf(docId);
    if (i < 0) return this;
    final next = [...documents];
    next[i] = next[i].copyWith(title: title);
    return copyWith(documents: next);
  }

  DocumentTab deleteDocument(String docId) =>
      copyWith(documents: documents.where((d) => d.id != docId).toList());
}

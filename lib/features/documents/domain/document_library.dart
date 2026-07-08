import 'package:freezed_annotation/freezed_annotation.dart';

import 'document_tab.dart';

part 'document_library.freezed.dart';
part 'document_library.g.dart';

/// Agrégat persisté d'une maison : ses onglets de documents, dans l'ordre.
/// Source de vérité locale (offline-first). Sérialisable = futur DTO serveur.
@freezed
abstract class DocumentLibrary with _$DocumentLibrary {
  const factory DocumentLibrary({
    required String householdId,
    @Default(<DocumentTab>[]) List<DocumentTab> tabs,
    // Horodatage de dernière mutation locale (LWW) : un état entrant plus
    // vieux que le nôtre est ignoré (protège les modifs faites hors ligne).
    DateTime? updatedAt,
  }) = _DocumentLibrary;
  const DocumentLibrary._();

  factory DocumentLibrary.fromJson(Map<String, dynamic> json) =>
      _$DocumentLibraryFromJson(json);

  int _indexOf(String tabId) => tabs.indexWhere((t) => t.id == tabId);

  DocumentTab? tabById(String tabId) {
    final i = _indexOf(tabId);
    return i < 0 ? null : tabs[i];
  }

  DocumentLibrary addTab(DocumentTab tab) => copyWith(tabs: [...tabs, tab]);

  DocumentLibrary renameTab(String tabId, String name) {
    final i = _indexOf(tabId);
    if (i < 0) return this;
    final next = [...tabs];
    next[i] = next[i].copyWith(name: name);
    return copyWith(tabs: next);
  }

  DocumentLibrary deleteTab(String tabId) =>
      copyWith(tabs: tabs.where((t) => t.id != tabId).toList());

  DocumentLibrary reorderTabs(List<String> orderedIds) {
    final byId = {for (final t in tabs) t.id: t};
    final reordered = [
      for (final id in orderedIds)
        if (byId[id] != null) byId[id]!,
    ];
    final missing = tabs.where((t) => !orderedIds.contains(t.id));
    return copyWith(tabs: [...reordered, ...missing]);
  }

  /// Remplace un onglet par sa version transformée (après édition de docs).
  DocumentLibrary replaceTab(DocumentTab tab) {
    final i = _indexOf(tab.id);
    if (i < 0) return this;
    final next = [...tabs];
    next[i] = tab;
    return copyWith(tabs: next);
  }
}

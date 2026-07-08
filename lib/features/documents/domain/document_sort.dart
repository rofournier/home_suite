import 'document.dart';

/// Critère de tri des documents d'un onglet.
enum DocSortField { date, title }

/// Tri courant : un champ + un sens. Vue uniquement (n'altère pas le stockage).
class DocumentSort {
  const DocumentSort({this.field = DocSortField.date, this.ascending = false});

  final DocSortField field;
  final bool ascending;

  DocumentSort withField(DocSortField field) =>
      DocumentSort(field: field, ascending: ascending);

  DocumentSort toggleOrder() =>
      DocumentSort(field: field, ascending: !ascending);

  String get label => switch (field) {
        DocSortField.date => 'Date',
        DocSortField.title => 'Titre',
      };
}

/// Trie une liste de documents selon [sort] (pur, testable). Le titre est
/// comparé sans casse ; à égalité, on départage par date pour un ordre stable.
List<Document> sortDocuments(List<Document> documents, DocumentSort sort) {
  final sorted = [...documents];
  int byDate(Document a, Document b) => a.createdAt.compareTo(b.createdAt);
  int byTitle(Document a, Document b) {
    final cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    return cmp != 0 ? cmp : byDate(a, b);
  }

  final comparator = switch (sort.field) {
    DocSortField.date => byDate,
    DocSortField.title => byTitle,
  };
  sorted.sort(comparator);
  return sort.ascending ? sorted : sorted.reversed.toList();
}

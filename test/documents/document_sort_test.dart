import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/documents/domain/document.dart';
import 'package:home_sweet_home/features/documents/domain/document_sort.dart';

Document doc(String id, String title, DateTime date) => Document(
      id: id,
      tabId: 't',
      title: title,
      imagePath: '/x/$id.jpg',
      createdBy: 'me',
      createdAt: date,
    );

void main() {
  final a = doc('a', 'Banane', DateTime(2026, 1, 1));
  final b = doc('b', 'ananas', DateTime(2026, 3, 1));
  final c = doc('c', 'Cerise', DateTime(2026, 2, 1));
  final docs = [a, b, c];

  test('tri par date décroissante (défaut)', () {
    final r = sortDocuments(docs, const DocumentSort());
    expect(r.map((d) => d.id), ['b', 'c', 'a']);
  });

  test('tri par date croissante', () {
    final r = sortDocuments(docs, const DocumentSort(ascending: true));
    expect(r.map((d) => d.id), ['a', 'c', 'b']);
  });

  test('tri par titre croissant, insensible à la casse', () {
    final r = sortDocuments(
        docs, const DocumentSort(field: DocSortField.title, ascending: true));
    expect(r.map((d) => d.id), ['b', 'a', 'c']); // ananas, Banane, Cerise
  });

  test('tri par titre décroissant', () {
    final r = sortDocuments(
        docs, const DocumentSort(field: DocSortField.title));
    expect(r.map((d) => d.id), ['c', 'a', 'b']);
  });

  test('ne mute pas la liste d\'entrée', () {
    final input = [a, b, c];
    sortDocuments(input, const DocumentSort());
    expect(input.map((d) => d.id), ['a', 'b', 'c']);
  });
}

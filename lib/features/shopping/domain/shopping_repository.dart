import 'shopping_item.dart';
import 'shopping_list.dart';

/// Accès à la liste de courses d'une maison. Le local est la source de vérité
/// (offline-first) ; l'impl publie aussi chaque mutation sur le `RealtimeService`
/// (plomberie server-ready — aucun effet visible tant qu'il n'y a pas de serveur).
///
/// Scopée à une maison au chargement : les mutations opèrent sur la liste
/// courante, pas besoin de repasser le `householdId`.
abstract interface class ShoppingRepository {
  /// Flux de la liste courante ; émet à chaque mutation. Première valeur =
  /// état persisté (onglets seedés au premier lancement).
  Stream<ShoppingList> watch();

  /// Ajoute un onglet ; renvoie son id (pour le sélectionner).
  Future<String> addCategory(String name);
  Future<void> renameCategory(String categoryId, String name);
  Future<void> deleteCategory(String categoryId);
  Future<void> reorderCategories(List<String> orderedIds);

  /// Ajoute un article vide en fin d'onglet ; renvoie l'article créé (focus UI).
  Future<ShoppingItem> addItem(String categoryId, {String text});
  Future<void> updateItemText(String categoryId, String itemId, String text);
  Future<void> toggleBought(String categoryId, String itemId);
  Future<void> deleteItem(String categoryId, String itemId);

  /// Réinsère un article supprimé à sa position (Undo). Conserve id/auteur/date.
  Future<void> restoreItem(String categoryId, ShoppingItem item, int index);

  /// Scinde l'article au curseur (Entrée) ; renvoie l'article créé (focus UI).
  Future<ShoppingItem> splitItem(String categoryId, String itemId, int cursor);

  /// Fusionne dans le précédent (Backspace ligne vide) ; renvoie l'article à
  /// focus et la position du curseur.
  Future<({String focusItemId, int cursor})> mergeItem(
      String categoryId, String itemId);

  Future<void> clearBought(String categoryId);

  /// Purge les articles vides d'un onglet (lignes ébauchées puis abandonnées).
  /// Appelé en quittant l'onglet/l'écran → évite de persister/synchroniser du
  /// vide. No-op s'il n'y a rien à retirer.
  Future<void> clearEmpty(String categoryId);

  /// Applique un état reçu d'un autre membre (temps réel) : remplace la liste
  /// locale et persiste, **sans** re-publier (pas de boucle). Ignoré si l'état
  /// entrant est plus vieux que le local (LWW — protège les modifs hors ligne).
  Future<void> applyRemote(ShoppingList list);

  /// Re-publie l'état local (appelé à chaque (re)connexion temps réel pour
  /// réconcilier après une période hors ligne).
  Future<void> republish();
}

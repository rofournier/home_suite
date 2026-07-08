import '../../../core/realtime/realtime_service.dart';
import '../domain/shopping_item.dart';

/// Types d'évènements temps réel de la liste de courses. Publiés par l'impl
/// à chaque mutation ; consommés par l'UI (notif). V1 no-op → jamais reçus.
abstract final class ShoppingEvents {
  static const itemAdded = 'shopping.item_added';
  static const changed = 'shopping.changed';

  /// Porte l'état complet de la liste (`payload['list']`). Le serveur le
  /// persiste et le rediffuse ; les autres membres remplacent leur liste.
  static const sync = 'shopping.sync';
}

/// Construit l'évènement de synchronisation portant l'état complet de la liste.
RealtimeEvent shoppingSyncEvent(Map<String, dynamic> listJson) => RealtimeEvent(
      type: ShoppingEvents.sync,
      payload: {'list': listJson},
    );

/// Construit l'évènement « article ajouté » (celui qui déclenche la notif).
/// Le payload porte de quoi afficher « Marie → Pommes (Frais) » sans relookup.
RealtimeEvent itemAddedEvent({
  required String householdId,
  required String categoryId,
  required String categoryName,
  required String authorName,
  required ShoppingItem item,
}) =>
    RealtimeEvent(
      type: ShoppingEvents.itemAdded,
      payload: {
        'householdId': householdId,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'authorName': authorName,
        'item': item.toJson(),
      },
    );

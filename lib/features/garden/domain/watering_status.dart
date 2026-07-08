import 'plant.dart';

/// État de soif d'une plante, dérivé du dernier arrosage et de la fréquence.
/// Logique pure → testée unitairement.
enum WateringStatus {
  /// Échéance dépassée (ou jamais arrosée) : à arroser maintenant.
  thirsty,

  /// Échéance dans les 24 h : à surveiller.
  soon,

  /// Rien à faire.
  fresh,
}

/// Prochaine échéance d'arrosage, ou `null` si jamais arrosée (due immédiate).
DateTime? nextWateringDue(Plant plant) =>
    plant.lastWateredAt?.add(Duration(days: plant.waterEveryDays));

WateringStatus wateringStatus(Plant plant, DateTime now) {
  final due = nextWateringDue(plant);
  if (due == null || !now.isBefore(due)) return WateringStatus.thirsty;
  if (due.difference(now) <= const Duration(hours: 24)) {
    return WateringStatus.soon;
  }
  return WateringStatus.fresh;
}

/// Libellé d'échéance : « À arroser ! », « Aujourd'hui », « Dans 3 j »,
/// « En retard de 2 j ».
String wateringDueLabel(Plant plant, DateTime now) {
  final due = nextWateringDue(plant);
  if (due == null) return 'À arroser !';
  final delta = due.difference(now);
  if (delta.isNegative) {
    final days = (-delta.inHours / 24).ceil();
    return 'En retard de $days j';
  }
  if (delta <= const Duration(hours: 24)) return 'Aujourd\'hui';
  return 'Dans ${(delta.inHours / 24).ceil()} j';
}

/// « Arrosée il y a 2 j », « Arrosée aujourd'hui », ou « Jamais arrosée ».
String lastWateredLabel(Plant plant, DateTime now) {
  final last = plant.lastWateredAt;
  if (last == null) return 'Jamais arrosée';
  final days = now.difference(last).inDays;
  if (days <= 0) return 'Arrosée aujourd\'hui';
  return 'Arrosée il y a $days j';
}

/// Prochaine échéance d'engrais, ou `null` si suivi désactivé. Jamais nourrie
/// avec suivi actif → due immédiate (null de `lastFedAt`).
DateTime? nextFeedingDue(Plant plant) {
  final every = plant.feedEveryDays;
  if (every == null) return null;
  return plant.lastFedAt?.add(Duration(days: every));
}

/// État de faim (engrais), ou `null` si le suivi est désactivé.
WateringStatus? feedingStatus(Plant plant, DateTime now) {
  if (plant.feedEveryDays == null) return null;
  final due = nextFeedingDue(plant);
  if (due == null || !now.isBefore(due)) return WateringStatus.thirsty;
  if (due.difference(now) <= const Duration(hours: 24)) {
    return WateringStatus.soon;
  }
  return WateringStatus.fresh;
}

/// Libellé d'échéance d'engrais : « Engrais ! », « Aujourd'hui », « Dans 12 j »,
/// « En retard de 3 j ». `null` si suivi désactivé.
String? feedingDueLabel(Plant plant, DateTime now) {
  if (plant.feedEveryDays == null) return null;
  final due = nextFeedingDue(plant);
  if (due == null) return 'Engrais !';
  final delta = due.difference(now);
  if (delta.isNegative) {
    final days = (-delta.inHours / 24).ceil();
    return 'En retard de $days j';
  }
  if (delta <= const Duration(hours: 24)) return 'Aujourd\'hui';
  return 'Dans ${(delta.inHours / 24).ceil()} j';
}

/// Une plante a-t-elle un besoin immédiat (eau OU engrais) ?
bool needsCare(Plant plant, DateTime now) =>
    wateringStatus(plant, now) == WateringStatus.thirsty ||
    feedingStatus(plant, now) == WateringStatus.thirsty;

/// Tri d'affichage dans une pièce : assoiffées d'abord, puis échéance proche.
List<Plant> sortByThirst(List<Plant> plants, DateTime now) {
  final sorted = [...plants];
  sorted.sort((a, b) {
    final dueA = nextWateringDue(a);
    final dueB = nextWateringDue(b);
    if (dueA == null && dueB == null) return a.name.compareTo(b.name);
    if (dueA == null) return -1; // jamais arrosée = plus urgent
    if (dueB == null) return 1;
    return dueA.compareTo(dueB);
  });
  return sorted;
}

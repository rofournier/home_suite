import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/garden/domain/plant.dart';
import 'package:home_sweet_home/features/garden/domain/watering_status.dart';
import 'package:home_sweet_home/features/household/domain/room.dart';

Plant plant({DateTime? last, int every = 3, String name = 'Ficus'}) => Plant(
      id: name,
      name: name,
      room: Room.salon,
      waterEveryDays: every,
      lastWateredAt: last,
      createdBy: 'me',
      createdAt: DateTime(2026, 7, 1),
    );

void main() {
  final now = DateTime(2026, 7, 8, 12);

  test('jamais arrosée → assoiffée, libellé « À arroser ! »', () {
    final p = plant(last: null);
    expect(wateringStatus(p, now), WateringStatus.thirsty);
    expect(wateringDueLabel(p, now), 'À arroser !');
    expect(lastWateredLabel(p, now), 'Jamais arrosée');
  });

  test('échéance dépassée → assoiffée, retard en jours', () {
    final p = plant(last: DateTime(2026, 7, 3, 12), every: 3); // due 6/7
    expect(wateringStatus(p, now), WateringStatus.thirsty);
    expect(wateringDueLabel(p, now), 'En retard de 2 j');
  });

  test('échéance sous 24 h → bientôt, « Aujourd\'hui »', () {
    final p = plant(last: DateTime(2026, 7, 6, 0), every: 3); // due 9/7 0h
    expect(wateringStatus(p, now), WateringStatus.soon);
    expect(wateringDueLabel(p, now), 'Aujourd\'hui');
  });

  test('échéance lointaine → fraîche, « Dans X j »', () {
    final p = plant(last: DateTime(2026, 7, 8, 10), every: 7);
    expect(wateringStatus(p, now), WateringStatus.fresh);
    expect(wateringDueLabel(p, now), 'Dans 7 j');
    expect(lastWateredLabel(p, now), 'Arrosée aujourd\'hui');
  });

  test('engrais non suivi → statut et libellé null', () {
    final p = plant(last: now);
    expect(feedingStatus(p, now), isNull);
    expect(feedingDueLabel(p, now), isNull);
    expect(needsCare(p.copyWith(lastWateredAt: now), now), isFalse);
  });

  test('engrais suivi jamais donné → faim (« Engrais ! »)', () {
    final p = plant(last: now).copyWith(feedEveryDays: 30);
    expect(feedingStatus(p, now), WateringStatus.thirsty);
    expect(feedingDueLabel(p, now), 'Engrais !');
    expect(needsCare(p, now), isTrue); // faim même si bien arrosée
  });

  test('engrais donné récemment → frais, échéance en jours', () {
    final p = plant(last: now).copyWith(
        feedEveryDays: 30, lastFedAt: DateTime(2026, 7, 1, 12));
    expect(feedingStatus(p, now), WateringStatus.fresh);
    expect(feedingDueLabel(p, now), 'Dans 23 j');
  });

  test('engrais en retard → assoiffée d\'engrais', () {
    final p = plant(last: now).copyWith(
        feedEveryDays: 14, lastFedAt: DateTime(2026, 6, 1));
    expect(feedingStatus(p, now), WateringStatus.thirsty);
    expect(feedingDueLabel(p, now), startsWith('En retard'));
  });

  test('tri : jamais arrosée d\'abord, puis échéance croissante', () {
    final never = plant(last: null, name: 'Jamais');
    final overdue = plant(last: DateTime(2026, 7, 1), every: 2, name: 'Retard');
    final fresh = plant(last: DateTime(2026, 7, 8), every: 14, name: 'Frais');
    final sorted = sortByThirst([fresh, overdue, never], now);
    expect(sorted.map((p) => p.name), ['Jamais', 'Retard', 'Frais']);
  });
}

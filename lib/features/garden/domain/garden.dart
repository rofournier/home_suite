import 'package:freezed_annotation/freezed_annotation.dart';

import '../../household/domain/room.dart';
import 'plant.dart';

part 'garden.freezed.dart';
part 'garden.g.dart';

/// Nombre d'arrosages conservés par plante (borne la taille de la sync).
const int maxWateringHistory = 20;

/// Agrégat persisté d'une maison : ses plantes. LWW via `updatedAt`, même
/// mécanique que les autres agrégats. Transformations pures → testables.
@freezed
abstract class Garden with _$Garden {
  const factory Garden({
    required String householdId,
    @Default(<Plant>[]) List<Plant> plants,
    DateTime? updatedAt,
  }) = _Garden;
  const Garden._();

  factory Garden.fromJson(Map<String, dynamic> json) => _$GardenFromJson(json);

  int _indexOf(String plantId) => plants.indexWhere((p) => p.id == plantId);

  Plant? plantById(String plantId) {
    final i = _indexOf(plantId);
    return i < 0 ? null : plants[i];
  }

  Garden addPlant(Plant plant) => copyWith(plants: [...plants, plant]);

  Garden replacePlant(Plant plant) {
    final i = _indexOf(plant.id);
    if (i < 0) return this;
    final next = [...plants];
    next[i] = plant;
    return copyWith(plants: next);
  }

  Garden removePlant(String plantId) =>
      copyWith(plants: plants.where((p) => p.id != plantId).toList());

  /// Arrose une plante : met à jour dernier arrosage + historique plafonné.
  Garden waterPlant(String plantId, {required String by, required DateTime at}) {
    final plant = plantById(plantId);
    if (plant == null) return this;
    return replacePlant(_watered(plant, by: by, at: at));
  }

  /// Arrose toutes les plantes d'une pièce d'un coup.
  Garden waterRoom(Room room, {required String by, required DateTime at}) {
    var garden = this;
    for (final plant in plants.where((p) => p.room == room)) {
      garden = garden.replacePlant(_watered(plant, by: by, at: at));
    }
    return garden;
  }

  Plant _watered(Plant plant, {required String by, required DateTime at}) =>
      plant.copyWith(
        lastWateredAt: at,
        lastWateredBy: by,
        history: [
          WateringEntry(by: by, at: at),
          ...plant.history,
        ].take(maxWateringHistory).toList(),
      );

  /// Donne de l'engrais à une plante : même mécanique que l'arrosage.
  Garden feedPlant(String plantId, {required String by, required DateTime at}) {
    final plant = plantById(plantId);
    if (plant == null) return this;
    return replacePlant(plant.copyWith(
      lastFedAt: at,
      lastFedBy: by,
      feedHistory: [
        WateringEntry(by: by, at: at),
        ...plant.feedHistory,
      ].take(maxWateringHistory).toList(),
    ));
  }

  /// Pièces contenant au moins une plante, dans l'ordre de l'enum.
  List<Room> get roomsWithPlants => [
        for (final room in Room.values)
          if (plants.any((p) => p.room == room)) room,
      ];

  List<Plant> plantsIn(Room room) =>
      plants.where((p) => p.room == room).toList();
}

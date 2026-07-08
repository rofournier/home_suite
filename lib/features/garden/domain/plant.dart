import 'package:freezed_annotation/freezed_annotation.dart';

import '../../household/domain/room.dart';

part 'plant.freezed.dart';
part 'plant.g.dart';

/// Une plante du foyer. `photoPath` = copie locale (peut manquer sur un autre
/// appareil) ; `fileId` = binaire uploadé. `history` = derniers arrosages
/// (plafonné côté agrégat pour borner la sync).
@freezed
abstract class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String name,
    required Room room,
    String? photoPath,
    String? fileId,
    required int waterEveryDays,
    DateTime? lastWateredAt,
    String? lastWateredBy,
    // Engrais : suivi optionnel (null = pas de suivi pour cette plante).
    int? feedEveryDays,
    DateTime? lastFedAt,
    String? lastFedBy,
    @Default('') String note,
    required String createdBy,
    required DateTime createdAt,
    @Default(<WateringEntry>[]) List<WateringEntry> history,
    @Default(<WateringEntry>[]) List<WateringEntry> feedHistory,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

/// Un arrosage : qui, quand.
@freezed
abstract class WateringEntry with _$WateringEntry {
  const factory WateringEntry({
    required String by,
    required DateTime at,
  }) = _WateringEntry;

  factory WateringEntry.fromJson(Map<String, dynamic> json) =>
      _$WateringEntryFromJson(json);
}

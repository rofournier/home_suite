import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_tokens.dart';
import '../../household/domain/room.dart';
import '../../shopping/presentation/shopping_providers.dart'
    show realtimeConnectionProvider;
import '../domain/garden.dart';
import '../domain/plant.dart';
import '../domain/watering_status.dart';
import 'garden_providers.dart';
import 'widgets/plant_details_sheet.dart';
import 'widgets/plant_form_sheet.dart';
import 'widgets/plant_photo.dart';
import 'widgets/watering_actions.dart';

/// 🌿 Jardin — les plantes du foyer par pièce, look champêtre. Arrosage
/// individuel ou par pièce, rappels visuels selon l'échéance.
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeConnectionProvider);
    ref.watch(gardenSyncProvider);
    final gardenAsync = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: AppColors.meadow,
      appBar: AppBar(
        backgroundColor: AppColors.meadow,
        foregroundColor: AppColors.ink,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Jardin'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlantFormSheet(context, ref),
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.onDopamine,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle plante'),
      ),
      body: SafeArea(
        top: false,
        child: gardenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Impossible de charger le jardin')),
          data: (garden) => garden.plants.isEmpty
              ? const _EmptyGarden()
              : _GardenList(garden: garden),
        ),
      ),
    );
  }
}

class _GardenList extends ConsumerWidget {
  const _GardenList({required this.garden});

  final Garden garden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final thirsty = garden.plants
        .where((p) => wateringStatus(p, now) == WateringStatus.thirsty)
        .length;
    final hungry = garden.plants
        .where((p) => feedingStatus(p, now) == WateringStatus.thirsty)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 96),
      children: [
        _DueHeader(thirsty: thirsty, hungry: hungry),
        for (final room in garden.roomsWithPlants) ...[
          _RoomHeader(
            room: room,
            plants: garden.plantsIn(room),
            now: now,
            onWaterAll: () => waterRoomWithUndo(context, ref, room),
          ),
          for (final plant in sortByThirst(garden.plantsIn(room), now))
            _PlantCard(plant: plant, now: now),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Bandeau d'état global : rappels eau/engrais ou félicitations.
class _DueHeader extends StatelessWidget {
  const _DueHeader({required this.thirsty, required this.hungry});

  final int thirsty;
  final int hungry;

  @override
  Widget build(BuildContext context) {
    final ok = thirsty == 0 && hungry == 0;
    final parts = [
      if (thirsty > 0) '💧 $thirsty plante${thirsty > 1 ? 's ont' : ' a'} soif',
      if (hungry > 0) '🌱 $hungry ${hungry > 1 ? 'ont' : 'a'} faim d\'engrais',
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: ok ? AppColors.sage : AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Text(
        ok ? '🌿 Tout le monde est comblé !' : parts.join(' · '),
        style: TextStyle(
          color: ok ? AppColors.onDopamine : AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.room,
    required this.plants,
    required this.now,
    required this.onWaterAll,
  });

  final Room room;
  final List<Plant> plants;
  final DateTime now;
  final VoidCallback onWaterAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${room.label} · ${plants.length}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.ink),
          ),
        ),
        TextButton.icon(
          onPressed: onWaterAll,
          icon: const Icon(Icons.water_drop_outlined, size: 18),
          label: const Text('Tout arroser'),
          style: TextButton.styleFrom(foregroundColor: AppColors.sage),
        ),
      ],
    );
  }
}

class _PlantCard extends ConsumerWidget {
  const _PlantCard({required this.plant, required this.now});

  final Plant plant;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = wateringStatus(plant, now);
    return Card(
      color: AppColors.paper,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: status == WateringStatus.thirsty
              ? AppColors.terracotta
              : AppColors.sand,
          width: status == WateringStatus.thirsty ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => showPlantDetailsSheet(context, ref, plant),
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              PlantPhoto(plant: plant, status: status, size: 64),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text(lastWateredLabel(plant, now),
                        style: const TextStyle(
                            color: AppColors.inkSoft, fontSize: 13)),
                    Text('💧 ${wateringDueLabel(plant, now)}',
                        style: TextStyle(
                            color: statusColor(status),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (feedingDueLabel(plant, now) case final feedLabel?)
                      Text('🌱 $feedLabel',
                          style: TextStyle(
                              color:
                                  statusColor(feedingStatus(plant, now)!),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => waterPlantWithUndo(context, ref, plant),
                tooltip: 'Arroser',
                icon: const Icon(Icons.water_drop_outlined),
                color: AppColors.sage,
                iconSize: 26,
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  const _EmptyGarden();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪴', style: TextStyle(fontSize: 44)),
          const SizedBox(height: AppSpacing.sm),
          Text('Aucune plante',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.ink)),
          const SizedBox(height: AppSpacing.xs),
          const Text('Plante ta première avec le bouton +',
              style: TextStyle(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

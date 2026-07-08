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

/// 🌿 Jardin — les plantes du foyer, un onglet par pièce habitée, look
/// champêtre. Arrosage individuel ou par pièce, rappels selon l'échéance.
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
              : _GardenTabs(garden: garden),
        ),
      ),
    );
  }
}

class _GardenTabs extends StatelessWidget {
  const _GardenTabs({required this.garden});

  final Garden garden;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rooms = garden.roomsWithPlants;
    final thirsty = garden.plants
        .where((p) => wateringStatus(p, now) == WateringStatus.thirsty)
        .length;
    final hungry = garden.plants
        .where((p) => feedingStatus(p, now) == WateringStatus.thirsty)
        .length;
    return DefaultTabController(
      // Recréé quand l'ensemble des pièces change (plante ajoutée/déplacée).
      key: ValueKey(rooms.map((r) => r.name).join('|')),
      length: rooms.length,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: _DueHeader(thirsty: thirsty, hungry: hungry),
          ),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.inkSoft,
            indicatorColor: AppColors.sage,
            dividerColor: AppColors.sand,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              for (final room in rooms)
                Tab(text: '${room.label} · ${garden.plantsIn(room).length}'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final room in rooms)
                  _RoomTab(
                      room: room, plants: garden.plantsIn(room), now: now),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenu d'un onglet pièce : « Tout arroser » + plantes triées par soif.
class _RoomTab extends ConsumerWidget {
  const _RoomTab({required this.room, required this.plants, required this.now});

  final Room room;
  final List<Plant> plants;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => waterRoomWithUndo(context, ref, room),
            icon: const Icon(Icons.water_drop_outlined, size: 18),
            label: const Text('Tout arroser'),
            style: TextButton.styleFrom(foregroundColor: AppColors.sage),
          ),
        ),
        for (final plant in sortByThirst(plants, now))
          _PlantCard(plant: plant, now: now),
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

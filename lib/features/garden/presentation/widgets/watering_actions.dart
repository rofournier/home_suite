import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/domain/room.dart';
import '../../domain/plant.dart';
import '../garden_providers.dart';

/// Arrose une plante avec snackbar Annuler (restaure l'état précédent).
Future<void> waterPlantWithUndo(
    BuildContext context, WidgetRef ref, Plant plant) async {
  final repo = ref.read(gardenRepositoryProvider);
  final previous = await repo.waterPlant(plant.id);
  if (previous == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text('💧 ${plant.name} arrosée !'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Annuler',
        onPressed: () => repo.restorePlants([previous]),
      ),
    ),
  );
}

/// Donne de l'engrais avec snackbar Annuler (restaure l'état précédent).
Future<void> feedPlantWithUndo(
    BuildContext context, WidgetRef ref, Plant plant) async {
  final repo = ref.read(gardenRepositoryProvider);
  final previous = await repo.feedPlant(plant.id);
  if (previous == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text('🌱 ${plant.name} nourrie !'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Annuler',
        onPressed: () => repo.restorePlants([previous]),
      ),
    ),
  );
}

/// Arrose toute une pièce avec snackbar Annuler (restaure tous les états).
Future<void> waterRoomWithUndo(
    BuildContext context, WidgetRef ref, Room room) async {
  final repo = ref.read(gardenRepositoryProvider);
  final previous = await repo.waterRoom(room);
  if (previous.isEmpty || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
          '💧 ${previous.length} plante${previous.length > 1 ? 's' : ''} '
          'arrosée${previous.length > 1 ? 's' : ''} (${room.label}) !'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Annuler',
        onPressed: () => repo.restorePlants(previous),
      ),
    ),
  );
}

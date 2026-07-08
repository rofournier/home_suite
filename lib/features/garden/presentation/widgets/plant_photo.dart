import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../documents/presentation/document_providers.dart'
    show documentRemoteProvider;
import '../../domain/plant.dart';
import '../../domain/watering_status.dart';

/// Couleur d'état de soif (anneau des photos, chips).
Color statusColor(WateringStatus status) => switch (status) {
      WateringStatus.thirsty => AppColors.terracotta,
      WateringStatus.soon => AppColors.amber,
      WateringStatus.fresh => AppColors.sage,
    };

/// Photo ronde d'une plante, entourée de l'anneau d'état de soif.
/// Locale si présente, sinon réseau authentifié, sinon 🪴.
class PlantPhoto extends ConsumerWidget {
  const PlantPhoto({
    super.key,
    required this.plant,
    required this.status,
    this.size = 72,
  });

  final Plant plant;
  final WateringStatus status;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.meadow,
        border: Border.all(color: statusColor(status), width: 3),
      ),
      child: ClipOval(child: _image(ref)),
    );
  }

  Widget _image(WidgetRef ref) =>
      plantImage(ref, plant, cacheWidth: 220, fallback: const _Placeholder());
}

/// La photo d'une plante (locale → réseau → [fallback]), sans forme imposée.
/// Partagé entre la miniature ronde (liste) et la bannière (détails).
Widget plantImage(WidgetRef ref, Plant plant,
    {required int cacheWidth, required Widget fallback}) {
  final path = plant.photoPath;
  if (path != null && File(path).existsSync()) {
    return Image.file(File(path), fit: BoxFit.cover, cacheWidth: cacheWidth);
  }
  final remote = ref.watch(documentRemoteProvider);
  final fileId = plant.fileId;
  if (remote != null && fileId != null) {
    return Image.network(
      remote.fileUri(fileId).toString(),
      headers: remote.authHeaders,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => fallback,
    );
  }
  return fallback;
}

/// Vraie photo disponible (locale ou distante) ? Sinon on affichera un
/// placeholder — utile pour adapter la hauteur de la bannière des détails.
bool hasPlantImage(Plant plant) {
  final path = plant.photoPath;
  return (path != null && File(path).existsSync()) || plant.fileId != null;
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('🪴', style: TextStyle(fontSize: 28, height: 1)),
      );
}

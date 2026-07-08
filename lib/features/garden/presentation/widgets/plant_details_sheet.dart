import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../household/presentation/household_providers.dart';
import '../../domain/plant.dart';
import '../../domain/watering_status.dart';
import '../garden_providers.dart';
import 'plant_form_sheet.dart';
import 'plant_photo.dart';
import 'watering_actions.dart';

/// Ce que l'utilisateur a choisi dans la page de détails. L'action est
/// exécutée par l'appelant (contexte de l'écran jardin, qui survit au pop) —
/// indispensable pour les snackbars Annuler.
enum _DetailsAction { water, feed, edit, delete }

/// Détails d'une plante : photo **plein écran en arrière-plan**, sheet papier
/// tirable par-dessus (la photo reste visible au-dessus de la sheet).
Future<void> showPlantDetailsSheet(
    BuildContext context, WidgetRef ref, Plant plant) async {
  final reduceMotion = MediaQuery.of(context).disableAnimations;
  final action = await Navigator.of(context).push<_DetailsAction>(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 240),
      reverseTransitionDuration:
          Duration(milliseconds: reduceMotion ? 0 : 180),
      pageBuilder: (_, _, _) => _PlantDetailsPage(plant: plant),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
  if (!context.mounted) return;
  switch (action) {
    case _DetailsAction.water:
      await waterPlantWithUndo(context, ref, plant);
    case _DetailsAction.feed:
      await feedPlantWithUndo(context, ref, plant);
    case _DetailsAction.edit:
      await showPlantFormSheet(context, ref, initial: plant);
    case _DetailsAction.delete:
      final ok = await _confirmDelete(context, plant.name);
      if (ok && context.mounted) {
        await ref.read(gardenRepositoryProvider).deletePlant(plant.id);
      }
    case null:
      break;
  }
}

class _PlantDetailsPage extends ConsumerWidget {
  const _PlantDetailsPage({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.meadow,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // La photo n'occupe QUE la bande au-dessus de la sheet (62 % :
          // affleure la sheet à sa hauteur minimale 38 %). Le recadrage
          // `cover` se centre ainsi sur la zone visible — le sujet de la
          // photo n'est pas mangé par la sheet.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.62,
            child: hasPlantImage(plant)
                ? plantImage(ref, plant,
                    cacheWidth: 1200, fallback: const _BigPlaceholder())
                : const _BigPlaceholder(),
          ),
          // Voile en haut : lisibilité du bouton fermer sur photo claire.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: _CloseButton(onTap: () => Navigator.of(context).pop()),
              ),
            ),
          ),
          _DraggableContent(plant: plant),
        ],
      ),
    );
  }
}

/// La sheet papier tirable par-dessus la photo : contenu scrollable + actions
/// épinglées en bas de la sheet.
class _DraggableContent extends ConsumerWidget {
  const _DraggableContent({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.38,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
          boxShadow: [
            BoxShadow(color: Color(0x33000000), blurRadius: 16),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                children: [_Body(plant: plant)],
              ),
            ),
            _Actions(plant: plant),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final status = wateringStatus(plant, now);
    final household = ref.watch(householdProvider);
    String nameOf(String id) =>
        household.members
            .where((m) => m.id == id)
            .map((m) => m.displayName)
            .firstOrNull ??
        'Quelqu\'un';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(plant.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppColors.ink)),
            ),
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pop(_DetailsAction.edit),
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit_outlined, color: AppColors.inkSoft),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
        Text(
          '${plant.room.label} · eau tous les ${plant.waterEveryDays} j'
          '${plant.feedEveryDays != null ? ' · engrais tous les ${plant.feedEveryDays} j' : ''}',
          style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Seule l'échéance : le « arrosée … par X » vit dans Derniers soins.
        Text(
          '💧 ${wateringDueLabel(plant, now)}',
          style: TextStyle(
              color: statusColor(status),
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        if (feedingDueLabel(plant, now) case final feedLabel?)
          Text(
            '🌱 $feedLabel',
            style: TextStyle(
                color: statusColor(feedingStatus(plant, now)!),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        if (plant.note.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('📝 ${plant.note}',
              style: const TextStyle(color: AppColors.inkSoft)),
        ],
        if (plant.history.isNotEmpty || plant.feedHistory.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Derniers soins',
              style:
                  TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          for (final entry in _careLog(plant))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                '${entry.emoji} ${_stamp(entry.at)} — ${nameOf(entry.by)}',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
              ),
            ),
        ],
      ],
    );
  }
}

/// Actions épinglées en bas de la sheet : Arroser / Engrais + suppression.
class _Actions extends StatelessWidget {
  const _Actions({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sage,
                        foregroundColor: AppColors.onDopamine,
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(_DetailsAction.water),
                      icon: const Icon(Icons.water_drop_outlined),
                      label: const Text('Arroser'),
                    ),
                  ),
                ),
                if (plant.feedEveryDays != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.ink,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () =>
                            Navigator.of(context).pop(_DetailsAction.feed),
                        icon: const Icon(Icons.compost_outlined),
                        label: const Text('Engrais'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(_DetailsAction.delete),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.terracotta, size: 20),
              label: const Text('Supprimer la plante',
                  style: TextStyle(color: AppColors.terracotta)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.close_rounded, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _BigPlaceholder extends StatelessWidget {
  const _BigPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: AppColors.meadow,
        child: Center(child: Text('🪴', style: TextStyle(fontSize: 72))),
      );
}

/// Journal fusionné arrosages 💧 + engrais 🌱, du plus récent au plus ancien.
List<({String emoji, DateTime at, String by})> _careLog(Plant plant) {
  final log = [
    for (final e in plant.history) (emoji: '💧', at: e.at, by: e.by),
    for (final e in plant.feedHistory) (emoji: '🌱', at: e.at, by: e.by),
  ];
  log.sort((a, b) => b.at.compareTo(a.at));
  return log;
}

String _stamp(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)} ${two(d.hour)}h${two(d.minute)}';
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer « $name » ?'),
      content: const Text('La plante et son historique seront perdus.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

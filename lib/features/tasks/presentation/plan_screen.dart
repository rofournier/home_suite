import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_tokens.dart';
import '../../shopping/presentation/shopping_providers.dart'
    show realtimeConnectionProvider;
import '../domain/house_task.dart';
import '../domain/plan_layout.dart';
import '../domain/task_board.dart';
import 'task_notif.dart';
import 'task_providers.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/leaderboard_sheet.dart';
import 'widgets/star_burst.dart';
import 'widgets/task_banner.dart';
import 'widgets/task_details_sheet.dart';
import 'widgets/task_pin.dart';

/// 🗺️ Plan interactif — paysage forcé (asset paysage). Tap sur le plan →
/// épingler une tâche ; tap sur un pin → détails / terminer.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(taskNotifProvider.notifier).resetHubUnseen());
  }

  @override
  void dispose() {
    // Le reste de l'app (hub dollhouse) est conçu portrait.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(realtimeConnectionProvider);
    ref.watch(taskSyncProvider);
    final boardAsync = ref.watch(taskBoardProvider);
    final taskCount = boardAsync.asData?.value.tasks.length ?? 0;

    return Scaffold(
      body: DecoratedBox(
        // Fond chaud lofi (dégradé cream→sand) plutôt que le scaffold brut.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cream, AppColors.sand],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: boardAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(
                      child: Text('Impossible de charger le plan')),
                  data: (board) => _PlanCanvas(board: board),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _BackButton(onTap: () => context.pop()),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TrophyButton(
                        onTap: () => showLeaderboardSheet(context, ref)),
                    const SizedBox(width: AppSpacing.sm),
                    _TaskCountChip(count: taskCount),
                  ],
                ),
              ),
              const Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.md,
                child: _SeverityLegend(),
              ),
              const Positioned(
                top: AppSpacing.sm,
                left: 0,
                right: 0,
                child: Center(child: TaskNotifBanner()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le plan + ses pins, calés sur le rect réel de l'image (contain centré).
/// Détecte les tâches disparues pour jouer une explosion d'étoiles à leur
/// position (célébration de complétion).
class _PlanCanvas extends ConsumerStatefulWidget {
  const _PlanCanvas({required this.board});

  final TaskBoard board;

  @override
  ConsumerState<_PlanCanvas> createState() => _PlanCanvasState();
}

class _PlanCanvasState extends ConsumerState<_PlanCanvas> {
  late Map<String, HouseTask> _known = _index(widget.board);
  final _bursts = <({int key, double x, double y})>[];
  int _burstKey = 0;

  Map<String, HouseTask> _index(TaskBoard board) =>
      {for (final t in board.tasks) t.id: t};

  @override
  void didUpdateWidget(covariant _PlanCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = _index(widget.board);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      for (final entry in _known.entries) {
        if (current.containsKey(entry.key)) continue;
        final burst = (key: _burstKey++, x: entry.value.x, y: entry.value.y);
        _bursts.add(burst);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _bursts.remove(burst));
        });
      }
    }
    _known = current;
  }

  TaskBoard get board => widget.board;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plan = containedPlanRect(constraints.biggest);
          return Stack(
            children: [
              Positioned.fromRect(
                rect: plan,
                child: GestureDetector(
                  onTapUp: (details) =>
                      _onPlanTap(context, ref, details.localPosition, plan),
                  // Carte « papier posé » : ombre douce + liseré sable.
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      border: Border.all(color: AppColors.sand, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.button - 2),
                      child: Image.asset('assets/plan.png', fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              for (final task in board.tasks)
                _pinAt(
                  context,
                  denormalizeInPlan(Offset(task.x, task.y), plan),
                  task,
                ),
              // Explosions d'étoiles là où des tâches viennent de disparaître.
              for (final burst in _bursts)
                Positioned(
                  left:
                      denormalizeInPlan(Offset(burst.x, burst.y), plan).dx - 32,
                  top:
                      denormalizeInPlan(Offset(burst.x, burst.y), plan).dy - 32,
                  child: StarBurst(key: ValueKey(burst.key)),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Tap sur le plan (coordonnées locales à l'image) → feuille d'ajout.
  void _onPlanTap(
      BuildContext context, WidgetRef ref, Offset local, Rect plan) {
    final normalized = Offset(local.dx / plan.width, local.dy / plan.height);
    showAddTaskSheet(context, ref, x: normalized.dx, y: normalized.dy);
  }

  Widget _pinAt(BuildContext context, Offset center, HouseTask task) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Positioned(
      left: center.dx - 24,
      top: center.dy - 24,
      // Pop d'apparition : le pin « atterrit » (scale easeOutBack).
      child: TweenAnimationBuilder<double>(
        key: ValueKey(task.id),
        tween: Tween(begin: reduceMotion ? 1 : 0.4, end: 1),
        duration: Duration(milliseconds: reduceMotion ? 0 : 260),
        curve: Curves.easeOutBack,
        builder: (_, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: TaskPin(
          task: task,
          onTap: () => showTaskDetailsSheet(context, ref, task),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

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
          child: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Ouvre le leaderboard 🏆.
class _TrophyButton extends StatelessWidget {
  const _TrophyButton({required this.onTap});

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
          child: Center(
            child: Text('🏆', style: TextStyle(fontSize: 20, height: 1)),
          ),
        ),
      ),
    );
  }
}

/// Compteur de tâches en cours — le score à faire baisser.
class _TaskCountChip extends StatelessWidget {
  const _TaskCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = switch (count) {
      0 => 'Tout est fait !',
      1 => '1 tâche',
      _ => '$count tâches',
    };
    return Material(
      color: count == 0 ? AppColors.sage : AppColors.paper,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Text(
          count == 0 ? '🎉 $label' : label,
          style: TextStyle(
            color: count == 0 ? AppColors.onDopamine : AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Légende des sévérités (pastilles colorées), discrète en bas à droite.
class _SeverityLegend extends StatelessWidget {
  const _SeverityLegend();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var s = 1; s <= 3; s++) ...[
              if (s > 1) const SizedBox(width: AppSpacing.sm),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: severityColor(s), shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(severityLabel(s),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../task_notif.dart';

/// Bannière lofi éphémère : « Marie → Vaisselle · Cuisine » (ajout) ou
/// « Suleyman a fait : Vaisselle » (complétion). Auto-effacement ~3 s.
class TaskNotifBanner extends ConsumerStatefulWidget {
  const TaskNotifBanner({super.key});

  @override
  ConsumerState<TaskNotifBanner> createState() => _TaskNotifBannerState();
}

class _TaskNotifBannerState extends ConsumerState<TaskNotifBanner> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleDismiss() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3),
        () => ref.read(taskNotifProvider.notifier).dismissBanner());
  }

  @override
  Widget build(BuildContext context) {
    final banner = ref.watch(taskNotifProvider.select((s) => s.banner));
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (banner != null) _scheduleDismiss();

    return AnimatedSwitcher(
      duration: Duration(milliseconds: reduceMotion ? 0 : 220),
      child: banner == null ? const SizedBox.shrink() : _Card(banner: banner),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.banner});

  final TaskBanner banner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = '${banner.categoryEmoji} ${banner.categoryLabel}';
    final text = switch (banner.kind) {
      TaskBannerKind.added =>
        '${banner.authorName} → $subject · ${banner.roomLabel}',
      TaskBannerKind.completed => '${banner.authorName} a fait : $subject',
      TaskBannerKind.validated => '${banner.authorName} a validé : $subject',
      TaskBannerKind.rejected =>
        '${banner.authorName} a refusé : $subject 😬',
    };
    final (icon, color) = switch (banner.kind) {
      TaskBannerKind.added => (Icons.push_pin_outlined, AppColors.terracotta),
      TaskBannerKind.completed => (Icons.celebration_outlined, AppColors.sage),
      TaskBannerKind.validated => (Icons.verified_outlined, AppColors.sage),
      TaskBannerKind.rejected =>
        (Icons.replay_rounded, AppColors.terracotta),
    };
    return Material(
      color: AppColors.sand,
      borderRadius: BorderRadius.circular(AppRadii.button),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

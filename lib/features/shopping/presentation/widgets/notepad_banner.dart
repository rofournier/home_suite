import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../shopping_notif.dart';
import '../shopping_providers.dart';

/// Bannière lofi éphémère « Marie → Pommes · Frais » à l'arrivée d'un article
/// d'un coéquipier. Auto-effacement ~3 s ; tap → ouvre l'onglet concerné.
/// V1 : ne s'affiche jamais (flux temps réel no-op).
class NotepadBanner extends ConsumerStatefulWidget {
  const NotepadBanner({super.key});

  @override
  ConsumerState<NotepadBanner> createState() => _NotepadBannerState();
}

class _NotepadBannerState extends ConsumerState<NotepadBanner> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleDismiss() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3),
        () => ref.read(shoppingNotifProvider.notifier).dismissBanner());
  }

  void _open(ShoppingBanner banner) {
    _timer?.cancel();
    ref.read(activeCategoryProvider.notifier).select(banner.categoryId);
    ref.read(shoppingNotifProvider.notifier)
      ..markCategorySeen(banner.categoryId)
      ..dismissBanner();
  }

  @override
  Widget build(BuildContext context) {
    final banner = ref.watch(shoppingNotifProvider.select((s) => s.banner));
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (banner != null) _scheduleDismiss();

    return AnimatedSwitcher(
      duration: Duration(milliseconds: reduceMotion ? 0 : 220),
      child: banner == null
          ? const SizedBox.shrink()
          : _Card(banner: banner, onTap: () => _open(banner)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.banner, required this.onTap});

  final ShoppingBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Material(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.add_shopping_cart_rounded,
                    color: AppColors.terracotta, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${banner.authorName} → ${banner.itemText} · ${banner.categoryName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_tokens.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_list.dart';
import 'shopping_notif.dart';
import 'shopping_providers.dart';
import 'widgets/category_tabs.dart';
import 'widgets/notepad_banner.dart';
import 'widgets/notepad_list.dart';

/// 🛒 Liste de courses collaborative — écran bloc-note à onglets.
class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  @override
  void initState() {
    super.initState();
    // Ouverture depuis le HUB → on éteint la notif dopamine.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(shoppingNotifProvider.notifier).resetHubUnseen());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(realtimeConnectionProvider); // maintient la connexion temps réel
    ref.watch(shoppingSyncProvider); // applique les états reçus des autres
    final listAsync = ref.watch(shoppingListProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Courses'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.paper),
        child: SafeArea(
          top: false,
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ErrorView(
                onRetry: () => ref.invalidate(shoppingListProvider)),
            data: (list) => _Loaded(list: list),
          ),
        ),
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (list.categories.isEmpty) {
      return const _EmptyView();
    }
    final active = _effectiveActive(ref);
    final category = list.categoryById(active) ?? list.categories.first;
    return Column(
      children: [
        const NotepadBanner(),
        CategoryTabs(categories: list.categories, activeId: category.id),
        if (category.boughtCount > 0) _ClearBoughtBar(category: category),
        Expanded(
          child: NotepadList(key: ValueKey(category.id), category: category),
        ),
      ],
    );
  }

  /// Réconcilie l'onglet actif : défaut = premier ; si l'actif a disparu
  /// (supprimé), retombe sur le premier.
  String _effectiveActive(WidgetRef ref) {
    final selected = ref.watch(activeCategoryProvider);
    final ids = list.categories.map((c) => c.id).toSet();
    if (selected != null && ids.contains(selected)) return selected;
    return list.categories.first.id;
  }
}

class _ClearBoughtBar extends ConsumerWidget {
  const _ClearBoughtBar({required this.category});

  final ShoppingCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: TextButton.icon(
          onPressed: () => ref
              .read(shoppingRepositoryProvider)
              .clearBought(category.id),
          icon: const Icon(Icons.cleaning_services_outlined, size: 18),
          label: Text('Nettoyer(${category.boughtCount})'),
          style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Aucun onglet',
          style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Impossible de charger la liste'),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../household/presentation/household_providers.dart';
import '../data/shopping_events.dart';

/// Une notif in-app éphémère (« Marie → Pommes · Frais »).
class ShoppingBanner {
  const ShoppingBanner({
    required this.authorName,
    required this.itemText,
    required this.categoryId,
    required this.categoryName,
  });

  final String authorName;
  final String itemText;
  final String categoryId;
  final String categoryName;
}

/// État des notifications de courses : bannière courante, badges « nouveau »
/// par onglet (in-app), compteur non-vus pour le HUB (dopamine).
class ShoppingNotifState {
  const ShoppingNotifState({
    this.banner,
    this.unseenByCategory = const {},
    this.hubUnseen = 0,
  });

  final ShoppingBanner? banner;
  final Map<String, int> unseenByCategory;
  final int hubUnseen;

  ShoppingNotifState copyWith({
    ShoppingBanner? banner,
    bool clearBanner = false,
    Map<String, int>? unseenByCategory,
    int? hubUnseen,
  }) =>
      ShoppingNotifState(
        banner: clearBanner ? null : (banner ?? this.banner),
        unseenByCategory: unseenByCategory ?? this.unseenByCategory,
        hubUnseen: hubUnseen ?? this.hubUnseen,
      );
}

/// Écoute les évènements temps réel entrants et en dérive l'état de notif.
/// V1 : `RealtimeService` no-op → flux vide, rien ne se déclenche (validé par
/// tests avec flux injecté). Ignore les évènements émis par soi-même.
class ShoppingNotifNotifier extends Notifier<ShoppingNotifState> {
  @override
  ShoppingNotifState build() {
    final me = ref.watch(currentMemberProvider).id;
    final sub = ref.watch(realtimeServiceProvider).events.listen(
          (event) => _onEvent(event, me),
        );
    ref.onDispose(sub.cancel);
    return const ShoppingNotifState();
  }

  void _onEvent(RealtimeEvent event, String meId) {
    if (event.type != ShoppingEvents.itemAdded) return;
    final payload = event.payload;
    if (payload == null) return;
    final item = payload['item'] as Map<String, dynamic>?;
    if (item != null && item['createdBy'] == meId) return; // pas d'auto-notif

    final categoryId = payload['categoryId'] as String? ?? '';
    final next = Map<String, int>.from(state.unseenByCategory);
    next[categoryId] = (next[categoryId] ?? 0) + 1;

    state = state.copyWith(
      banner: ShoppingBanner(
        authorName: payload['authorName'] as String? ?? 'Quelqu\'un',
        itemText: item?['text'] as String? ?? '',
        categoryId: categoryId,
        categoryName: payload['categoryName'] as String? ?? '',
      ),
      unseenByCategory: next,
      hubUnseen: state.hubUnseen + 1,
    );
  }

  void dismissBanner() => state = state.copyWith(clearBanner: true);

  /// Onglet consulté → efface son badge « nouveau ».
  void markCategorySeen(String categoryId) {
    if ((state.unseenByCategory[categoryId] ?? 0) == 0) return;
    final next = Map<String, int>.from(state.unseenByCategory)..remove(categoryId);
    state = state.copyWith(unseenByCategory: next);
  }

  /// App Courses ouverte depuis le HUB → reset du compteur dopamine.
  void resetHubUnseen() {
    if (state.hubUnseen == 0) return;
    state = state.copyWith(hubUnseen: 0);
  }
}

final shoppingNotifProvider =
    NotifierProvider<ShoppingNotifNotifier, ShoppingNotifState>(
        ShoppingNotifNotifier.new);

/// Compteur non-vus exposé au HUB (badge + pulse dopamine sur le frigo).
final hubShoppingUnseenProvider =
    Provider<int>((ref) => ref.watch(shoppingNotifProvider).hubUnseen);

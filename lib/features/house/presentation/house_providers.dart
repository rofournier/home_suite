import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/shared_preferences_provider.dart';
import '../domain/house_version.dart';

/// Skin de maison sélectionné. **Préférence personnelle et locale** : persistée
/// dans `shared_preferences`, jamais envoyée au serveur ni partagée avec la
/// maison (chaque membre a son propre rendu).
class HouseVersionNotifier extends Notifier<HouseVersion> {
  static const _key = 'house_version';

  @override
  HouseVersion build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return HouseVersion.values.firstWhere(
      (v) => v.name == saved,
      orElse: () => HouseVersion.cosy,
    );
  }

  void select(HouseVersion version) {
    ref.read(sharedPreferencesProvider).setString(_key, version.name);
    state = version;
  }
}

final houseVersionProvider =
    NotifierProvider<HouseVersionNotifier, HouseVersion>(
        HouseVersionNotifier.new);

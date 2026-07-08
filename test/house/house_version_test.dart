import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/core/persistence/shared_preferences_provider.dart';
import 'package:home_sweet_home/features/house/domain/house_version.dart';
import 'package:home_sweet_home/features/house/presentation/house_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('défaut = cosy', () async {
    final c = await container();
    expect(c.read(houseVersionProvider), HouseVersion.cosy);
  });

  test('select persiste le skin et met à jour l\'état', () async {
    final c = await container();
    c.read(houseVersionProvider.notifier).select(HouseVersion.riad);
    expect(c.read(houseVersionProvider), HouseVersion.riad);

    // Un nouveau container (même prefs) relit le choix persisté.
    final prefs = await SharedPreferences.getInstance();
    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c2.dispose);
    expect(c2.read(houseVersionProvider), HouseVersion.riad);
  });
}

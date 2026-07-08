import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance partagée de `SharedPreferences`. Résolue au démarrage dans `main`
/// puis injectée via override → les providers y accèdent de façon synchrone.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('À surcharger dans main()'),
);

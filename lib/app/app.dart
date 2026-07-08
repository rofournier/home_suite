import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/weather/presentation/weather_providers.dart';
import 'realtime_binding.dart';
import 'router.dart';
import 'theme.dart';

class HomeSweetHomeApp extends ConsumerStatefulWidget {
  const HomeSweetHomeApp({super.key});

  @override
  ConsumerState<HomeSweetHomeApp> createState() => _HomeSweetHomeAppState();
}

class _HomeSweetHomeAppState extends ConsumerState<HomeSweetHomeApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refreshOnResume);
  }

  /// Retour au premier plan après une mise en veille : la météo (et donc le
  /// ciel jour/nuit du hub) peut dater, et Android a pu couper le socket.
  /// L'invalidation garde la valeur précédente pendant le re-fetch (pas de
  /// flash du ciel).
  void _refreshOnResume() {
    ref.invalidate(weatherProvider);
    ref.read(realtimeServiceProvider).wake();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Home Sweet Home',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

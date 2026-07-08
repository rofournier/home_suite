import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme_tokens.dart';
import '../../documents/presentation/document_providers.dart';
import '../../gallery/presentation/gallery_providers.dart';
import '../../garden/presentation/garden_providers.dart';
import '../../house/presentation/house_view.dart';
import '../../shopping/presentation/shopping_providers.dart';
import '../../tasks/presentation/task_providers.dart';
import '../../weather/presentation/weather_card.dart';
import '../../weather/presentation/weather_indicator.dart';
import '../../weather/presentation/weather_panel_providers.dart';
import 'hub_providers.dart';
import 'sky_background.dart';
import 'weather_effects.dart';

/// Le HUB : ciel dynamique + effets météo derrière, maison + hotspots devant,
/// indicateur météo permanent et carte 7 jours togglable.
class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(weatherSceneProvider);
    final panelOpen = ref.watch(weatherPanelOpenProvider);
    final topPad = MediaQuery.of(context).padding.top;
    // Temps réel actif dès le hub : reçoit notifs + sync des autres membres.
    ref.watch(realtimeConnectionProvider);
    ref.watch(shoppingSyncProvider);
    ref.watch(documentSyncProvider);
    ref.watch(taskSyncProvider);
    ref.watch(gallerySyncProvider);
    ref.watch(gardenSyncProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SkyBackground(
                condition: scene.condition, isDay: scene.isDay),
          ),
          Positioned.fill(child: WeatherEffects(scene: scene)),
          // La maison est ancrée en bas ; l'espace au-dessus accueille la météo.
          Positioned.fill(
            top: topPad + 88,
            child: const HouseView(),
          ),
          if (panelOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(weatherPanelOpenProvider.notifier).close(),
                child: const ColoredBox(color: Color(0x33000000)),
              ),
            ),
          Positioned(
            top: topPad + AppSpacing.sm,
            right: AppSpacing.md,
            child: const WeatherIndicator(),
          ),
          if (panelOpen)
            Positioned(
              top: topPad + 64,
              right: AppSpacing.md,
              child: const WeatherCard(),
            ),
        ],
      ),
    );
  }
}

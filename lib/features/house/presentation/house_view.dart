import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/destinations.dart';
import '../../garden/presentation/garden_providers.dart';
import '../../shopping/presentation/shopping_notif.dart';
import '../../tasks/presentation/task_notif.dart';
import '../domain/hotspot.dart';
import '../domain/house_layout.dart';
import '../domain/house_version.dart';
import 'house_placeholder_painter.dart';
import 'house_providers.dart';
import 'hotspot_widget.dart';

/// La maison + ses hotspots. Utilise le PNG généré si présent, sinon la
/// silhouette placeholder. Les hotspots sont positionnés en coords normalisées.
class HouseView extends ConsumerWidget {
  const HouseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(houseVersionProvider);
    final shoppingUnseen = ref.watch(hubShoppingUnseenProvider);
    final taskUnseen = ref.watch(hubTaskUnseenProvider);
    final gardenDue = ref.watch(hubGardenDueProvider);
    int badge(AppDestination destination) => switch (destination) {
          AppDestination.shopping => shoppingUnseen,
          AppDestination.housePlan => taskUnseen,
          AppDestination.garden => gardenDue,
          _ => 0,
        };
    return LayoutBuilder(
      builder: (context, constraints) {
        // Rect réel de l'image (contain + ancrage bas) → hotspots calés dessus.
        final image = containedHouseRect(constraints.biggest);
        return Stack(
          fit: StackFit.expand,
          children: [
            _HouseImage(version: version),
            for (final hotspot in defaultHotspots)
              _positioned(
                placeInHouse(hotspot.area, image),
                hotspot,
                badge(hotspot.destination),
              ),
          ],
        );
      },
    );
  }
}

Widget _positioned(Rect rect, Hotspot hotspot, int badgeCount) =>
    Positioned.fromRect(
      rect: rect,
      child:
          HotspotWidget(destination: hotspot.destination, badgeCount: badgeCount),
    );

class _HouseImage extends StatelessWidget {
  const _HouseImage({required this.version});

  final HouseVersion version;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      version.asset,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      // Tant que le PNG n'est pas fourni : silhouette dessinée.
      errorBuilder: (context, error, stack) => CustomPaint(
        size: Size.infinite,
        painter: HousePlaceholderPainter(version),
      ),
    );
  }
}

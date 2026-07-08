import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../app/theme_tokens.dart';

/// Zone tappable sur un objet de la maison : scintille au repos, rebondit +
/// halo au tap (avec haptique), puis ouvre la route de l'app.
///
/// [badgeCount] > 0 (ex. articles de courses non-vus) : ajoute un **badge
/// compteur** + une **pulsation chaude « dopamine »** plus marquée que le glint.
class HotspotWidget extends StatefulWidget {
  const HotspotWidget({
    super.key,
    required this.destination,
    this.badgeCount = 0,
  });

  final AppDestination destination;
  final int badgeCount;

  @override
  State<HotspotWidget> createState() => _HotspotWidgetState();
}

class _HotspotWidgetState extends State<HotspotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _glint =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
  late final AnimationController _press = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));

  @override
  void dispose() {
    _glint.dispose();
    _press.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.lightImpact();
    await _press.forward(from: 0);
    if (mounted) context.push(widget.destination.route);
    if (mounted) _press.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final dopamine = widget.badgeCount > 0;
    final color = dopamine
        ? AppColors.dopamine
        : Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: dopamine
          ? '${widget.destination.label}, ${widget.badgeCount} nouveaux'
          : widget.destination.label,
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_glint, _press]),
                builder: (_, _) {
                  final press = Curves.easeOut.transform(_press.value);
                  final glint = reduceMotion
                      ? 0.0
                      : 0.5 + 0.5 * sin(_glint.value * 2 * pi);
                  return Transform.scale(
                    scale: 1 - 0.06 * press,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _HotspotPainter(
                          glint: glint,
                          halo: press,
                          color: color,
                          dopamine: dopamine),
                    ),
                  );
                },
              ),
            ),
            if (dopamine)
              Positioned(
                top: -6,
                right: -6,
                child: IgnorePointer(child: _Badge(count: widget.badgeCount)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pastille compteur chaude collée au hotspot (dopamine).
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.dopamine,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.onDopamine, width: 1.5),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: AppColors.onDopamine,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _HotspotPainter extends CustomPainter {
  _HotspotPainter({
    required this.glint,
    required this.halo,
    required this.color,
    this.dopamine = false,
  });

  final double glint;
  final double halo;
  final Color color;
  final bool dopamine;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
        rect.deflate(2), const Radius.circular(14));

    // Dopamine : halo chaud diffus qui « respire » (plus marqué que le glint).
    if (dopamine) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.10 + 0.14 * glint)
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, size.shortestSide * (0.10 + 0.06 * glint)),
      );
    }

    // Scintillement / contour qui pulse (plus intense en mode dopamine).
    final strokeMax = dopamine ? 0.55 : 0.34;
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = dopamine ? 2.5 : 2
        ..color = color.withValues(alpha: 0.12 + (strokeMax - 0.12) * glint)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Halo au tap : anneau qui s'étend et s'estompe.
    if (halo > 0) {
      final radius = size.shortestSide * (0.35 + 0.4 * halo);
      canvas.drawCircle(
        rect.center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.5 * (1 - halo)),
      );
    }
  }

  @override
  bool shouldRepaint(_HotspotPainter oldDelegate) =>
      oldDelegate.glint != glint ||
      oldDelegate.halo != halo ||
      oldDelegate.dopamine != dopamine ||
      oldDelegate.color != color;
}

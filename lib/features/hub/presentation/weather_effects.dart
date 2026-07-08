import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/domain/weather_condition.dart';
import '../domain/weather_scene.dart';
import 'cloud_sprites.dart';

/// Effets météo animés au-dessus/autour de la maison : nuages (sprites peints,
/// dérive ∝ vent), pluie, neige, brouillard, éclairs. Étoiles gérées par
/// [SkyBackground]. Les sprites tombent sur un rendu procédural le temps du
/// décodage (voir [cloudSpritesProvider]).
class WeatherEffects extends ConsumerStatefulWidget {
  const WeatherEffects({super.key, required this.scene});

  final WeatherScene scene;

  @override
  ConsumerState<WeatherEffects> createState() => _WeatherEffectsState();
}

class _WeatherEffectsState extends ConsumerState<WeatherEffects>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat();
  final _rng = Random(42);
  late final List<_Particle> _precip = List.generate(
    140,
    (_) => _Particle(
      _rng.nextDouble(),
      _rng.nextDouble(),
      _rng.nextDouble() * 0.5 + 0.5,
      _rng.nextDouble(),
    ),
  );
  late final List<_Particle> _clouds = List.generate(
    6,
    (_) => _Particle(
      _rng.nextDouble() * 1.2,
      _rng.nextDouble() * 0.32 + 0.03,
      _rng.nextDouble() * 0.4 + 0.2,
      _rng.nextDouble() * 0.5 + 0.6,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final sprites = ref.watch(cloudSpritesProvider).asData?.value;
    _WeatherPainter painterAt(double t) => _WeatherPainter(
          t: t,
          scene: widget.scene,
          precip: _precip,
          clouds: _clouds,
          sprites: sprites,
        );
    if (reduceMotion) {
      return CustomPaint(size: Size.infinite, painter: painterAt(0));
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size.infinite,
          painter: painterAt(_controller.value),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle(this.x, this.y, this.speed, this.seed);
  final double x, y, speed, seed;
}

class _WeatherPainter extends CustomPainter {
  _WeatherPainter({
    required this.t,
    required this.scene,
    required this.precip,
    required this.clouds,
    required this.sprites,
  });

  final double t;
  final WeatherScene scene;
  final List<_Particle> precip;
  final List<_Particle> clouds;
  final CloudSprites? sprites;

  @override
  void paint(Canvas canvas, Size size) {
    final condition = scene.condition;
    final wind = (scene.windSpeed / 40).clamp(0.15, 1.6);

    if (condition != SkyCondition.clear) {
      final images = _pool(sprites);
      if (images == null) {
        _paintCloudBlobs(canvas, size, wind);
      } else {
        _paintCloudSprites(canvas, size, wind, images);
      }
    }
    switch (condition) {
      case SkyCondition.rain || SkyCondition.thunderstorm:
        _paintRain(canvas, size, wind);
      case SkyCondition.snow:
        _paintSnow(canvas, size, wind);
      case SkyCondition.fog:
        _paintFog(canvas, size);
      default:
        break;
    }
    if (condition == SkyCondition.thunderstorm) {
      _paintLightning(canvas, size);
    }
  }

  /// Gabarits de nuages adaptés à la condition (null si sprites non chargés).
  List<ui.Image>? _pool(CloudSprites? s) {
    if (s == null) return null;
    return switch (scene.condition) {
      SkyCondition.thunderstorm => s.storm,
      SkyCondition.partlyCloudy => [...s.small, s.medium.first],
      _ => [...s.medium, s.large],
    };
  }

  /// Nombre de nuages visibles selon la condition.
  int get _cloudCount => switch (scene.condition) {
        SkyCondition.partlyCloudy => 3,
        SkyCondition.thunderstorm => 4,
        _ => 6,
      };

  void _paintCloudSprites(
      Canvas canvas, Size size, double wind, List<ui.Image> pool) {
    final dense = scene.condition == SkyCondition.cloudy ||
        scene.condition == SkyCondition.thunderstorm;
    final tint = scene.isDay ? Colors.white : const Color(0xFFAEB0C4);
    final baseOpacity =
        scene.isDay ? (dense ? 0.98 : 0.85) : (dense ? 0.8 : 0.6);
    final visible = clouds.take(_cloudCount).toList();
    for (var i = 0; i < visible.length; i++) {
      final cloud = visible[i];
      final img = pool[i % pool.length];
      final x = ((cloud.x + t * cloud.speed * wind) % 1.35 - 0.2) * size.width;
      final y = cloud.y * size.height;
      final dstW = size.width * (0.24 + 0.18 * cloud.seed);
      final dstH = dstW * img.height / img.width;
      final opacity = baseOpacity * (0.72 + 0.28 * cloud.seed);
      // FilterQuality.low : bilinéaire sans mipmaps. `medium` génère une
      // pyramide de mips qui moyenne la couleur du nuage sur tout le sprite →
      // voile rectangulaire visible sur ciel plat.
      final paint = Paint()
        ..filterQuality = FilterQuality.low
        ..colorFilter = ColorFilter.mode(
            tint.withValues(alpha: opacity), BlendMode.modulate);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromCenter(center: Offset(x, y), width: dstW, height: dstH),
        paint,
      );
    }
  }

  /// Repli procédural (avant décodage des sprites).
  void _paintCloudBlobs(Canvas canvas, Size size, double wind) {
    final tint = scene.isDay ? Colors.white : const Color(0xFFB9B3C6);
    final dense = scene.condition == SkyCondition.cloudy ||
        scene.condition == SkyCondition.thunderstorm;
    final paint = Paint()
      ..color = tint.withValues(alpha: dense ? 0.85 : 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (final cloud in clouds.take(_cloudCount)) {
      final x = ((cloud.x + t * cloud.speed * wind) % 1.3 - 0.15) * size.width;
      final y = cloud.y * size.height;
      final w = size.width * (0.28 * cloud.seed + 0.18);
      _blob(canvas, Offset(x, y), w, paint);
    }
  }

  void _blob(Canvas canvas, Offset center, double width, Paint paint) {
    final h = width * 0.45;
    canvas.drawOval(
        Rect.fromCenter(center: center, width: width, height: h), paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(-width * 0.28, h * 0.15),
            width: width * 0.6,
            height: h * 0.8),
        paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: center.translate(width * 0.28, h * 0.1),
            width: width * 0.65,
            height: h * 0.85),
        paint);
  }

  void _paintRain(Canvas canvas, Size size, double wind) {
    final paint = Paint()
      ..color = const Color(0xFFCED6E0).withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final slant = 6 + wind * 14;
    for (final p in precip) {
      final y = ((p.y + t * (1.1 + p.speed)) % 1.15) * size.height -
          0.1 * size.height;
      final x = p.x * size.width + slant * (y / size.height);
      canvas.drawLine(Offset(x, y), Offset(x - slant * 0.4, y + 14), paint);
    }
  }

  void _paintSnow(Canvas canvas, Size size, double wind) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final p in precip) {
      final y = ((p.y + t * (0.25 + p.speed * 0.4)) % 1.1) * size.height;
      final sway = sin((t * 2 * pi) + p.seed * 6) * (6 + wind * 10);
      final x = p.x * size.width + sway;
      canvas.drawCircle(Offset(x, y), 1.4 + p.seed * 1.6, paint);
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final frac = i / 4;
      final shift = sin((t * 2 * pi) + i) * 20;
      final rect = Rect.fromLTWH(
          -20 + shift, size.height * (0.35 + frac * 0.5), size.width + 40, 60);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }
  }

  void _paintLightning(Canvas canvas, Size size) {
    final phase = (t * 3) % 1;
    if (phase >= 0.04) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35 * (1 - phase / 0.04)),
    );
  }

  @override
  bool shouldRepaint(_WeatherPainter oldDelegate) => true;
}

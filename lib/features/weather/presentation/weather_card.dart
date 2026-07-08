import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme_tokens.dart';
import '../../hub/presentation/hub_providers.dart';
import '../domain/weather.dart';
import '../domain/weather_condition.dart';
import 'weather_glyph.dart';
import 'weather_panel_providers.dart';
import 'weather_providers.dart';

const _weekdaysFr = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];

/// Carte météo « Apple-like » en glassmorphism : météo courante + bascule
/// horaire (temp + probabilité de précipitations) / 7 jours.
class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDay = ref.watch(weatherSceneProvider).isDay;
    final async = ref.watch(weatherProvider);
    final range = ref.watch(weatherRangeProvider);
    final onSurface = isDay ? AppColors.ink : AppColors.onNight;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(
          scale: 0.9 + 0.1 * v,
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
      // Absorbe les taps sur les zones inertes → seule l'extérieur (scrim)
      // ferme la carte ; les contrôles internes restent cliquables.
      child: GestureDetector(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (isDay ? Colors.white : AppColors.nightBase).withValues(
                  alpha: isDay ? 0.55 : 0.55,
                ),
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: switch (async) {
                AsyncData(:final value) => _Content(
                  weather: value,
                  color: onSurface,
                  range: range,
                  onRange: (r) =>
                      ref.read(weatherRangeProvider.notifier).set(r),
                ),
                AsyncError() => _Message(
                  text: 'Météo indisponible',
                  color: onSurface,
                  onRetry: () => ref.invalidate(weatherProvider),
                ),
                _ => _Message(
                  text: 'Chargement de la météo…',
                  color: onSurface,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.weather,
    required this.color,
    required this.range,
    required this.onRange,
  });

  final Weather weather;
  final Color color;
  final WeatherRange range;
  final ValueChanged<WeatherRange> onRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '${weather.temperature.round()}°',
              style: theme.textTheme.displaySmall?.copyWith(color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                weather.condition.label,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _RangeToggle(range: range, color: color, onRange: onRange),
        const SizedBox(height: AppSpacing.xs),
        Divider(color: color.withValues(alpha: 0.15)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (range == WeatherRange.hourly)
                  for (final hour in weather.hourly.take(24))
                    _HourRow(hour: hour, color: color)
                else
                  for (final day in weather.daily.take(7))
                    _DayRow(day: day, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bascule segmentée Heures / Jours (cibles ≥48dp).
class _RangeToggle extends StatelessWidget {
  const _RangeToggle({
    required this.range,
    required this.color,
    required this.onRange,
  });

  final WeatherRange range;
  final Color color;
  final ValueChanged<WeatherRange> onRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          _segment('Par heure', WeatherRange.hourly),
          _segment('7 jours', WeatherRange.daily),
        ],
      ),
    );
  }

  Widget _segment(String label, WeatherRange value) {
    final selected = range == value;
    return Expanded(
      child: Material(
        color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: selected ? null : () => onRange(value),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: selected ? 1 : 0.6),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({required this.hour, required this.color});

  final HourlyForecast hour;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final kind = hour.condition == SkyCondition.clear
        ? GlyphKind.sun
        : GlyphKind.cloud;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final pop = hour.precipitationProbability;
    final rainColor = color.withValues(alpha: pop > 0 ? 0.9 : 0.28);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('${hour.time.hour}h', style: style)),
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: WeatherGlyphPainter(kind: kind)),
          ),
          const Spacer(),
          Icon(Icons.water_drop_outlined, size: 14, color: rainColor),
          const SizedBox(width: 2),
          SizedBox(
            width: 40,
            child: Text(
              '$pop %',
              style: style?.copyWith(color: rainColor),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 34,
            child: Text(
              '${hour.temperature.round()}°',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.color});

  final DailyForecast day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = _weekdaysFr[day.date.weekday - 1];
    final kind = day.condition == SkyCondition.clear
        ? GlyphKind.sun
        : GlyphKind.cloud;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: style)),
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: WeatherGlyphPainter(kind: kind)),
          ),
          const Spacer(),
          Text(
            '${day.tempMin.round()}°',
            style: style?.copyWith(color: color.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${day.tempMax.round()}°', style: style),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.color, this.onRetry});

  final String text;
  final Color color;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: color),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

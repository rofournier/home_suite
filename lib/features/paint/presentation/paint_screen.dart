import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/theme_tokens.dart';
import '../../gallery/presentation/gallery_providers.dart';
import '../domain/stroke.dart';

/// 🎨 Dessin — canevas papier, pinceaux lofi. « Garder » enregistre le dessin
/// dans la Galerie (copie locale + upload + sync pour le foyer).
class PaintScreen extends ConsumerStatefulWidget {
  const PaintScreen({super.key});

  @override
  ConsumerState<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends ConsumerState<PaintScreen> {
  final _canvasKey = GlobalKey();
  final _strokes = <Stroke>[];
  Stroke? _current;
  Color _color = PaintPalette.colors.first;
  double _width = 6;
  bool _saving = false;

  void _start(Offset point) => setState(() {
        _current = Stroke(color: _color, width: _width, points: [point]);
      });

  void _move(Offset point) => setState(() {
        _current = _current?.extend(point);
      });

  void _end() => setState(() {
        if (_current != null && _current!.points.length > 1) {
          _strokes.add(_current!);
        } else if (_current != null) {
          // Simple tap : un point → petit pois quand même.
          _strokes.add(_current!.extend(_current!.points.first));
        }
        _current = null;
      });

  void _undo() => setState(() {
        if (_strokes.isNotEmpty) _strokes.removeLast();
      });

  void _clear() => setState(_strokes.clear);

  Future<void> _save() async {
    if (_strokes.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final boundary = _canvasKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final path = p.join(
          dir.path, 'drawing_${DateTime.now().millisecondsSinceEpoch}.png');
      await File(path).writeAsBytes(bytes!.buffer.asUint8List());

      await ref.read(galleryRepositoryProvider).addDrawing(
            sourcePath: path,
            title: _defaultTitle(DateTime.now()),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enregistré dans la Galerie !')),
        );
        setState(_strokes.clear);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'enregistrer.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Dessin'),
        actions: [
          IconButton(
            onPressed: _strokes.isEmpty ? null : _undo,
            tooltip: 'Annuler le trait',
            icon: const Icon(Icons.undo_rounded),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          IconButton(
            onPressed: _strokes.isEmpty ? null : _clear,
            tooltip: 'Tout effacer',
            icon: const Icon(Icons.delete_sweep_outlined),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _canvas()),
            _Toolbar(
              color: _color,
              width: _width,
              canSave: _strokes.isNotEmpty && !_saving,
              saving: _saving,
              onColor: (c) => setState(() => _color = c),
              onWidth: (w) => setState(() => _width = w),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _canvas() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: RepaintBoundary(
          key: _canvasKey,
          child: ColoredBox(
            color: AppColors.paper,
            child: GestureDetector(
              onPanStart: (d) => _start(d.localPosition),
              onPanUpdate: (d) => _move(d.localPosition),
              onPanEnd: (_) => _end(),
              onTapUp: (d) {
                _start(d.localPosition);
                _end();
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _StrokesPainter(
                  strokes: _strokes,
                  current: _current,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _defaultTitle(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Dessin du ${two(d.day)}/${two(d.month)}';
}

class _StrokesPainter extends CustomPainter {
  _StrokesPainter({required this.strokes, required this.current});

  final List<Stroke> strokes;
  final Stroke? current;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, ?current]) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokesPainter oldDelegate) => true;
}

/// Barre d'outils : pastilles de couleur, 3 épaisseurs, bouton Garder.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.color,
    required this.width,
    required this.canSave,
    required this.saving,
    required this.onColor,
    required this.onWidth,
    required this.onSave,
  });

  final Color color;
  final double width;
  final bool canSave;
  final bool saving;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onWidth;
  final VoidCallback onSave;

  static const _widths = [3.0, 6.0, 12.0];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in PaintPalette.colors)
                  _ColorDot(
                    color: c,
                    selected: c == color,
                    onTap: () => onColor(c),
                  ),
                const SizedBox(width: AppSpacing.md),
                for (final w in _widths)
                  _WidthDot(
                    width: w,
                    selected: w == width,
                    color: color,
                    onTap: () => onWidth(w),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: AppColors.onDopamine,
              ),
              onPressed: canSave ? onSave : null,
              icon: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Garder dans la Galerie'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: selected ? 34 : 28,
            height: selected ? 34 : 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.ink : AppColors.sand,
                width: selected ? 3 : 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WidthDot extends StatelessWidget {
  const _WidthDot({
    required this.width,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final double width;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: width + 10,
            height: width + 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.ink : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

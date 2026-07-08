import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme_tokens.dart';
import '../../../household/domain/room.dart';
import '../../domain/plant.dart';
import '../garden_providers.dart';

/// Feuille de création/édition d'une plante. Style papier (lisible sur tout
/// thème). Photo optionnelle (caméra/galerie). Fermer sans valider = no-op.
Future<void> showPlantFormSheet(BuildContext context, WidgetRef ref,
    {Plant? initial}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _PlantForm(
        initial: initial,
        onSubmit: (name, room, days, feedDays, note, photoSourcePath) {
          Navigator.of(sheetContext).pop();
          final repo = ref.read(gardenRepositoryProvider);
          if (initial == null) {
            repo.addPlant(
              name: name,
              room: room,
              waterEveryDays: days,
              feedEveryDays: feedDays,
              note: note,
              photoSourcePath: photoSourcePath,
            );
          } else {
            repo.updatePlant(
              initial.copyWith(
                  name: name,
                  room: room,
                  waterEveryDays: days,
                  feedEveryDays: feedDays,
                  note: note),
              photoSourcePath: photoSourcePath,
            );
          }
        },
      ),
    ),
  );
}

class _PlantForm extends StatefulWidget {
  const _PlantForm({required this.initial, required this.onSubmit});

  final Plant? initial;
  final void Function(String name, Room room, int waterEveryDays,
      int? feedEveryDays, String note, String? photoSourcePath) onSubmit;

  @override
  State<_PlantForm> createState() => _PlantFormState();
}

class _PlantFormState extends State<_PlantForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _note = TextEditingController(text: widget.initial?.note ?? '');
  late Room? _room = widget.initial?.room;
  late int _days = widget.initial?.waterEveryDays ?? 3;
  late int? _feedDays = widget.initial?.feedEveryDays;
  String? _photoSourcePath;

  static const _presets = [1, 2, 3, 7, 14];
  static const _feedPresets = [14, 30, 60];

  bool get _valid => _name.text.trim().isNotEmpty && _room != null;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.paper,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.ink),
              title: const Text('Prendre une photo',
                  style: TextStyle(color: AppColors.ink)),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.ink),
              title: const Text('Choisir dans la galerie',
                  style: TextStyle(color: AppColors.ink)),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (file != null) setState(() => _photoSourcePath = file.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de récupérer la photo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _PhotoButton(
                  picked: _photoSourcePath != null || editing,
                  onTap: _pickPhoto),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _field(_name, 'Nom de la plante')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _roomDropdown(),
          const SizedBox(height: AppSpacing.md),
          _frequency(),
          const SizedBox(height: AppSpacing.md),
          _feedFrequency(),
          const SizedBox(height: AppSpacing.md),
          _field(_note, 'Note (optionnel)', maxLines: 2),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.onDopamine,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _valid
                  ? () => widget.onSubmit(_name.text.trim(), _room!, _days,
                      _feedDays, _note.text.trim(), _photoSourcePath)
                  : null,
              child: Text(editing ? 'Enregistrer' : 'Planter 🌱'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
          {int maxLines = 1}) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: AppColors.ink),
        onChanged: (_) => setState(() {}),
        decoration: _decoration(label),
      );

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.inkSoft),
        isDense: true,
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: const BorderSide(color: AppColors.sand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: const BorderSide(color: AppColors.sand),
        ),
      );

  Widget _roomDropdown() => DropdownButtonFormField<Room>(
        initialValue: _room,
        dropdownColor: AppColors.paper,
        style: const TextStyle(color: AppColors.ink, fontSize: 15),
        iconEnabledColor: AppColors.inkSoft,
        decoration: _decoration('Pièce'),
        items: [
          for (final room in Room.values)
            DropdownMenuItem(value: room, child: Text(room.label)),
        ],
        onChanged: (room) => setState(() => _room = room),
      );

  Widget _frequency() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arroser tous les $_days jour${_days > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final preset in _presets)
                _DayChip(
                  days: preset,
                  selected: _days == preset,
                  onTap: () => setState(() => _days = preset),
                ),
              _Stepper(
                onMinus:
                    _days > 1 ? () => setState(() => _days -= 1) : null,
                onPlus:
                    _days < 60 ? () => setState(() => _days += 1) : null,
              ),
            ],
          ),
        ],
      );

  Widget _feedFrequency() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _feedDays == null
                ? 'Engrais : non suivi'
                : 'Engrais tous les $_feedDays jours',
            style: const TextStyle(
                color: AppColors.ink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _FeedOffChip(
                selected: _feedDays == null,
                onTap: () => setState(() => _feedDays = null),
              ),
              for (final preset in _feedPresets)
                _DayChip(
                  days: preset,
                  selected: _feedDays == preset,
                  onTap: () => setState(() => _feedDays = preset),
                ),
              if (_feedDays != null)
                _Stepper(
                  onMinus: _feedDays! > 1
                      ? () => setState(() => _feedDays = _feedDays! - 1)
                      : null,
                  onPlus: _feedDays! < 120
                      ? () => setState(() => _feedDays = _feedDays! + 1)
                      : null,
                ),
            ],
          ),
        ],
      );
}

/// Chip « Sans engrais » : désactive le suivi pour cette plante.
class _FeedOffChip extends StatelessWidget {
  const _FeedOffChip({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkSoft : AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: selected ? AppColors.inkSoft : AppColors.sand,
              width: 1.5),
        ),
        child: Text(
          'Sans',
          style: TextStyle(
            color: selected ? AppColors.onDopamine : AppColors.inkSoft,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.picked, required this.onTap});

  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.meadow,
          shape: BoxShape.circle,
          border: Border.all(
              color: picked ? AppColors.sage : AppColors.sand, width: 2),
        ),
        child: Icon(
          picked ? Icons.check_rounded : Icons.add_a_photo_outlined,
          color: picked ? AppColors.sage : AppColors.inkSoft,
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip(
      {required this.days, required this.selected, required this.onTap});

  final int days;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.sage : AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: selected ? AppColors.sage : AppColors.sand, width: 1.5),
        ),
        child: Text(
          '$days j',
          style: TextStyle(
            color: selected ? AppColors.onDopamine : AppColors.inkSoft,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.onMinus, required this.onPlus});

  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_rounded),
          color: AppColors.inkSoft,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_rounded),
          color: AppColors.inkSoft,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ],
    );
  }
}

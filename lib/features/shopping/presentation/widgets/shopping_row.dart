import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/shopping_item.dart';

const double kRowHeight = 48; // ≥48dp : cible tactile + calage réglure.

/// Style du texte d'un article : manuscrit (Caveat) par défaut, **repli sur la
/// typo de l'app** au-delà d'un fort text-scaling (lisibilité/accessibilité).
/// Barré + grisé quand acheté (contraste conservé ≥4.5:1).
TextStyle itemTextStyle(BuildContext context, {required bool bought}) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  final color = bought ? AppColors.boughtText : AppColors.ink;
  final decoration = bought ? TextDecoration.lineThrough : TextDecoration.none;
  if (scale > 1.3) {
    return TextStyle(
      fontSize: 17,
      color: color,
      decoration: decoration,
      decorationColor: AppColors.boughtText,
    );
  }
  return GoogleFonts.caveat(
    fontSize: 22,
    height: 1.1,
    color: color,
    decoration: decoration,
    decorationColor: AppColors.boughtText,
    decorationThickness: 2,
  );
}

/// Une ligne du bloc-note : case à cocher + champ manuscrit inline.
/// Swipe → suppression (avec Undo côté parent). La détection Entrée (split) et
/// Backspace-début (fusion) est gérée par le parent via [onEnter]/[focusNode].
class ShoppingRow extends StatelessWidget {
  const ShoppingRow({
    super.key,
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.highlighted,
    required this.onChanged,
    required this.onEnter,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingItem item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool highlighted;
  final ValueChanged<String> onChanged;
  final void Function(String before, String after) onEnter;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: const _DeleteBackground(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: reduceMotion ? 0 : 220),
        curve: Curves.easeOut,
        color: highlighted ? AppColors.insertHighlight : Colors.transparent,
        constraints: const BoxConstraints(minHeight: kRowHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CheckBox(bought: item.bought, onTap: onToggle),
            Expanded(child: _field(context)),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      style: itemTextStyle(context, bought: item.bought),
      cursorColor: AppColors.terracotta,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        hintText: 'Article…',
      ),
      onChanged: _handleChanged,
    );
  }

  void _handleChanged(String value) {
    if (!value.contains('\n')) {
      onChanged(value);
      return;
    }
    final idx = value.indexOf('\n');
    final before = value.substring(0, idx);
    final after = value.substring(idx + 1);
    controller.value = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: before.length),
    );
    onEnter(before, after);
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.bought, required this.onTap});

  final bool bought;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: bought,
      label: 'Acheté',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: kRowHeight,
          height: kRowHeight,
          child: Icon(
            bought ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: bought ? AppColors.sage : AppColors.inkSoft,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      color: AppColors.terracotta.withValues(alpha: 0.18),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.terracotta),
    );
  }
}

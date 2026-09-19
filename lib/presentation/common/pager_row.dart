import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

/// Prev/dots-or-count/next pager used by single-item practice screens
/// (flashcard, phonics) that step through a fixed list by index.
class PagerRow extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final ValueChanged<int> onGoTo;

  const PagerRow({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.onGoTo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPrev = currentIndex > 0;
    final canNext = currentIndex < itemCount - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NavCircle(
          icon: Icons.chevron_left_rounded,
          enabled: canPrev,
          onTap: () => onGoTo(currentIndex - 1),
        ),
        SizedBox(width: Insets.i16),
        if (itemCount <= 10)
          Row(
            children: List.generate(itemCount, (index) {
              final active = index == currentIndex;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.i3),
                child: Container(
                  width: active ? Sizes.s12 : Sizes.s8,
                  height: Sizes.s8,
                  decoration: BoxDecoration(
                    color: active ? colorScheme.primary : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.r6),
                  ),
                ),
              );
            }),
          )
        else
          Text(
            '${currentIndex + 1} / $itemCount',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        SizedBox(width: Insets.i16),
        NavCircle(
          icon: Icons.chevron_right_rounded,
          enabled: canNext,
          onTap: () => onGoTo(currentIndex + 1),
        ),
      ],
    );
  }
}

class NavCircle extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const NavCircle({super.key, required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.r24),
      child: Container(
        width: Sizes.s44,
        height: Sizes.s44,
        decoration: BoxDecoration(
          color: enabled ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: enabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

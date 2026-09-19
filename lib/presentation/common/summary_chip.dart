import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

/// A small "reassurance" pill (check icon + label) used on informational
/// screens (About, Privacy Policy) to call out a short factual claim about
/// the app, e.g. "Works fully offline".
class SummaryChip extends StatelessWidget {
  final String label;

  const SummaryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Insets.i12, vertical: Insets.i8),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: Sizes.s16, color: colorScheme.onTertiaryContainer),
          SizedBox(width: Insets.i6),
          Text(label, style: AppCss.captionSmall.size(13).semiBold.textColor(colorScheme.onTertiaryContainer)),
        ],
      ),
    );
  }
}

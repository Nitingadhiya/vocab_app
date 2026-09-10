import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

class StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const StatChip({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Insets.i16, horizontal: Insets.i8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            SizedBox(height: Insets.i6),
            Text(value, style: AppCss.bodyBaseSemibold.size(20).textColor(foregroundColor)),
            SizedBox(height: Insets.i2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppCss.captionSmall.size(12).textColor(foregroundColor.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}

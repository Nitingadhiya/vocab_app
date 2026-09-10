import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/models/index.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int wordCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.wordCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Container(
        padding: EdgeInsets.all(Insets.i16),
        decoration: BoxDecoration(
          color: category.colorHex.toColor(),
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 30)),
            SizedBox(height: Insets.i8),
            Text(
              category.name,
              style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface),
            ),
            SizedBox(height: Insets.i2),
            Text(
              '$wordCount+ words',
              style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

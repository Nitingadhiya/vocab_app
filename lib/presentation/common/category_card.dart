import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/models/index.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final int wordCount;
  final VoidCallback onTap;

  /// Position of this card within its grid, used to stagger the entrance
  /// animation so cards cascade in rather than popping in all at once.
  final int index;

  const CategoryCard({
    super.key,
    required this.category,
    required this.wordCount,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  static const _maxStagger = Duration(milliseconds: 240);
  static const _staggerStep = Duration(milliseconds: 50);

  bool _visible = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    final delay = _staggerStep * widget.index;
    Future.delayed(delay > _maxStagger ? _maxStagger : delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // The category tile background is a fixed pastel from content data (not
    // theme-driven) so it stays light in both light and dark mode — the text
    // on it must stay dark ink too, never colorScheme.onSurface (which turns
    // near-white in dark mode and disappears on a light pastel card).
    const ink = Color(0xFF201C3A);

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _visible ? 1 : 0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Container(
              padding: EdgeInsets.all(Insets.i16),
              decoration: BoxDecoration(
                color: widget.category.colorHex.toColor(),
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.category.emoji, style: const TextStyle(fontSize: 30)),
                  SizedBox(height: Insets.i8),
                  Text(
                    widget.category.name,
                    style: AppCss.bodySmallSemiBold.size(16).textColor(ink),
                  ),
                  SizedBox(height: Insets.i2),
                  Text(
                    '${widget.wordCount}+ words',
                    style: AppCss.captionSmall.textColor(ink.withValues(alpha: 0.65)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

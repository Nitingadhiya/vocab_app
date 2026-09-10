import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/scale.dart';

/// A colored rounded tile/circle with a big emoji centered in it.
class EmojiTile extends StatelessWidget {
  final String emoji;
  final Color backgroundColor;
  final double size;
  final double emojiSize;
  final BoxShape shape;
  final double borderRadius;

  const EmojiTile({
    super.key,
    required this.emoji,
    required this.backgroundColor,
    this.size = 56,
    double? emojiSize,
    this.shape = BoxShape.circle,
    this.borderRadius = AppRadius.r16,
  }) : emojiSize = emojiSize ?? size * 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
    );
  }
}

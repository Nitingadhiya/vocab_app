import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

/// Entry hub for the Phonics category — pick a learning mode. Follows the
/// See -> Hear -> Trace -> Recognize -> Match progression: Letter Sounds and
/// Letter Tracing are implemented; Recognition and Sound Matching are shown
/// as "coming soon" placeholders reserving their place in the flow.
class PhonicsHomePage extends StatelessWidget {
  const PhonicsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Phonics', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
      body: GridView(
        padding: EdgeInsets.all(Insets.i20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        children: [
          _ModeCard(
            emoji: '🔊',
            title: 'Letter Sounds',
            subtitle: 'See & hear A-Z',
            backgroundColor: const Color(0xFFFFE4C7),
            onTap: () => context.push('/category/phonics'),
          ),
          _ModeCard(
            emoji: '✍️',
            title: 'Letter Tracing',
            subtitle: 'Trace A-Z',
            backgroundColor: const Color(0xFFDCEEFB),
            onTap: () => context.push('/phonics/tracing/phonics_a'),
          ),
          _ModeCard(
            emoji: '🔎',
            title: 'Letter Recognition',
            subtitle: 'Coming soon',
            backgroundColor: colorScheme.surfaceContainerHighest,
            onTap: null,
          ),
          _ModeCard(
            emoji: '🎧',
            title: 'Sound Matching',
            subtitle: 'Coming soon',
            backgroundColor: colorScheme.surfaceContainerHighest,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Same fixed-pastel-background / dark-ink convention as CategoryCard so
    // this hub visually matches the rest of the app in both light and dark
    // mode (see CategoryCard for why onSurface isn't used here).
    const ink = Color(0xFF201C3A);
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Container(
        padding: EdgeInsets.all(Insets.i16),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppRadius.r16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            SizedBox(height: Insets.i8),
            Text(
              title,
              style: AppCss.bodySmallSemiBold.size(16).textColor(enabled ? ink : ink.withValues(alpha: 0.4)),
            ),
            SizedBox(height: Insets.i2),
            Text(subtitle, style: AppCss.captionSmall.textColor(ink.withValues(alpha: enabled ? 0.65 : 0.35))),
          ],
        ),
      ),
    );
  }
}

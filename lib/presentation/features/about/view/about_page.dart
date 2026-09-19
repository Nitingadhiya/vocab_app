import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/summary_chip.dart';

/// Static "About" screen — what the app does, who it's for, and how to
/// reach the developer or read the full privacy policy. Content only, no
/// cubit: nothing here changes at runtime.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('About Word Stars', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
      body: ListView(
        padding: EdgeInsets.all(Insets.i20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: Sizes.s64,
                  height: Sizes.s64,
                  decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('🔤', style: TextStyle(fontSize: 32)),
                ),
                SizedBox(height: Insets.i12),
                Text('Word Stars', style: AppCss.h6.textColor(colorScheme.onSurface)),
                SizedBox(height: Insets.i4),
                Text(
                  'A fun vocabulary learning app for curious little minds.',
                  textAlign: TextAlign.center,
                  style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                SizedBox(height: Insets.i12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Insets.i12, vertical: Insets.i6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: AppCss.captionSmall.size(12).semiBold.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Insets.i24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Insets.i8,
            runSpacing: Insets.i8,
            children: const [
              SummaryChip(label: 'No account needed'),
              SummaryChip(label: 'No ads or trackers'),
              SummaryChip(label: 'Works fully offline'),
            ],
          ),
          SizedBox(height: Insets.i30),
          Text("What's inside", style: AppCss.bodySmall.size(16).semiBold.textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i16),
          const _FeatureRow(
            icon: Icons.style_rounded,
            title: 'Flashcards & Categories',
            description: 'Explore words across Alphabet, Phonics, Animals, Food, Vehicles, Colors, and Nature.',
          ),
          const _FeatureRow(
            icon: Icons.record_voice_over_rounded,
            title: 'Phonics Practice',
            description: "Hear each letter's sound to build early reading skills.",
          ),
          const _FeatureRow(
            icon: Icons.edit_rounded,
            title: 'Letter Tracing',
            description: 'Trace all 26 letters on a playful, guided dotted-path canvas.',
          ),
          const _FeatureRow(
            icon: Icons.quiz_rounded,
            title: 'Listen & Choose Quizzes',
            description: 'Short quizzes reinforce the words learned in each category.',
          ),
          const _FeatureRow(
            icon: Icons.emoji_events_rounded,
            title: 'Progress & Streaks',
            description: 'Track words learned and daily streaks from the Progress tab.',
          ),
          SizedBox(height: Insets.i16),
          Text('Built for young learners', style: AppCss.bodySmall.size(16).semiBold.textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i8),
          Text(
            'Word Stars is designed for children ages 3 and up, best explored together with a parent or '
                "guardian. It works fully offline, so it's ready to go anywhere — no wifi, no accounts, no "
                'waiting.',
            style: AppCss.captionSmall.textHeight(1.5).textColor(colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          SizedBox(height: Insets.i24),
          InkWell(
            onTap: () => context.push('/settings/privacy-policy'),
            borderRadius: BorderRadius.circular(AppRadius.r16),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Insets.i12),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: colorScheme.primary, size: Sizes.s24),
                  SizedBox(width: Insets.i16),
                  Expanded(
                    child: Text('Read the Privacy Policy', style: AppCss.bodySmall.size(16).textColor(colorScheme.onSurface)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ),
          SizedBox(height: Insets.i16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Insets.i20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: Column(
              children: [
                Text(
                  'Made with ❤ by Krishna Developer',
                  style: AppCss.captionSmall.semiBold.textColor(colorScheme.onSurface.withValues(alpha: 0.8)),
                ),
                SizedBox(height: Insets.i4),
                Text(
                  'aksharsoft11@gmail.com',
                  style: AppCss.captionSmall.textColor(colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: Insets.i16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Sizes.s40,
            height: Sizes.s40,
            decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(AppRadius.r12)),
            alignment: Alignment.center,
            child: Icon(icon, color: colorScheme.onSecondaryContainer, size: Sizes.s20),
          ),
          SizedBox(width: Insets.i12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppCss.bodySmall.size(15).semiBold.textColor(colorScheme.onSurface)),
                SizedBox(height: Insets.i2),
                Text(
                  description,
                  style: AppCss.captionSmall.size(13).textHeight(1.4).textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

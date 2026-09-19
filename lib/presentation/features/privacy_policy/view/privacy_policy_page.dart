import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/summary_chip.dart';

/// Static, fully offline privacy policy — shown in-app (not just linked from
/// the store listing) since Word Stars targets young children and the
/// policy should be readable without a network connection.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Privacy Policy', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
      body: ListView(
        padding: EdgeInsets.all(Insets.i20),
        children: [
          Text(
            'Last updated: September 13, 2026',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          SizedBox(height: Insets.i16),
          Wrap(
            spacing: Insets.i8,
            runSpacing: Insets.i8,
            children: const [
              SummaryChip(label: 'No account needed'),
              SummaryChip(label: 'Nothing leaves the device'),
              SummaryChip(label: 'No ads or trackers'),
              SummaryChip(label: 'Works fully offline'),
            ],
          ),
          SizedBox(height: Insets.i24),
          const _Section(
            number: 1,
            title: 'What information we collect',
            paragraphs: [
              "Word Stars is built to run entirely on your device, so it asks for almost nothing. The only "
                  "information it ever handles is what you optionally type in yourself: a child's first name or "
                  "nickname (used only to personalize greetings), which words/letters/quizzes have been completed "
                  "(so progress and streaks can be shown), and simple preferences like favorited words, sound "
                  "on/off, and light/dark theme.",
              'Word Stars does not ask for an email address, phone number, photo, location, or any other '
                  'identifying information, and there is no account or sign-up step of any kind.',
            ],
          ),
          const _Section(
            number: 2,
            title: "Where it's stored",
            paragraphs: [
              "All of the information above is saved only in the app's local storage on your device. Word Stars "
                  "has no server, no login, and no internet connection requirement — it doesn't sync, back up, or "
                  "transmit any of it anywhere, to us or anyone else. Uninstalling the app permanently deletes "
                  "everything it stored.",
            ],
          ),
          const _Section(
            number: 3,
            title: 'Reading words aloud',
            paragraphs: [
              "Word Stars uses your device's built-in text-to-speech engine to read letters and words out loud. "
                  "This speech is generated on-device by your phone's operating system — no audio, text, or usage "
                  "data is sent to Word Stars, to us, or to any third-party speech service.",
            ],
          ),
          const _Section(
            number: 4,
            title: "Children's privacy",
            paragraphs: [
              "Word Stars is designed for young children to use, typically alongside a parent or guardian. We "
                  "built it around a simple rule: don't collect anything you wouldn't want a stranger to have, so "
                  "in practice we don't collect anything at all — no name tied to an identity, no contact details, "
                  "no device identifiers, no advertising ID.",
              'Because no personal information is collected, transmitted, or shared, there is nothing about a '
                  "child that could be sold, profiled, or exposed in a data breach.",
            ],
          ),
          const _Section(
            number: 5,
            title: 'Sharing & third parties',
            paragraphs: [
              'Word Stars contains no advertising, no analytics or crash-reporting tools, no third-party SDKs '
                  'that collect or process personal data, and no in-app purchases or payment processing. Since '
                  'nothing is collected, there is nothing to share, sell, or hand over to a third party.',
            ],
          ),
          const _Section(
            number: 6,
            title: "Your and your child's controls",
            paragraphs: [
              'Because everything lives on-device, you\'re already in full control: turn sound and text-to-speech '
                  'on or off any time from Settings, clear a child\'s name/progress/favorites by clearing the '
                  "app's storage in your device settings (or uninstalling the app), and use the app fully offline "
                  "— airplane mode doesn't change how it works.",
            ],
          ),
          const _Section(
            number: 7,
            title: 'Changes to this policy',
            paragraphs: [
              'If this policy ever changes — for example, if a future version of Word Stars adds a feature that '
                  'touches data differently — we\'ll update the "Last updated" date above and describe the change '
                  'here before it takes effect in an app update.',
            ],
          ),
          const _Section(
            number: 8,
            title: 'Contact us',
            paragraphs: [
              'Questions about this policy or how Word Stars handles information? Reach out any time:',
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: Insets.i4),
            child: Text('Krishna Developer', style: AppCss.captionSmall.semiBold.textColor(colorScheme.onSurface)),
          ),
          Text(
            'aksharsoft11@gmail.com',
            style: AppCss.captionSmall.textColor(colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final int number;
  final String title;
  final List<String> paragraphs;

  const _Section({required this.number, required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: Insets.i24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Sizes.s24,
                height: Sizes.s24,
                margin: EdgeInsets.only(top: Insets.i2, right: Insets.i8),
                decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: AppCss.captionSmall.size(12).bold.textColor(colorScheme.onPrimaryContainer),
                ),
              ),
              Expanded(
                child: Text(title, style: AppCss.bodySmall.size(16).semiBold.textColor(colorScheme.onSurface)),
              ),
            ],
          ),
          SizedBox(height: Insets.i8),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: EdgeInsets.only(bottom: Insets.i8),
              child: Text(
                paragraph,
                style: AppCss.captionSmall.textHeight(1.5).textColor(colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

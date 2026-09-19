import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/common/confetti_overlay.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/primary_button.dart';
import 'package:vocab_app/presentation/features/daily_challenge/viewmodel/daily_challenge_cubit.dart';

/// Opens the daily challenge as a modal bottom sheet. Shared by the home
/// card and the once-per-launch prompt so both run the exact same quiz.
Future<void> showDailyChallengeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // Home sits inside the bottom-nav shell's nested navigator; without this
    // the sheet opens *under* the nav bar, leaving it visible and tappable.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r24))),
    builder: (_) => BlocProvider(
      create: (_) => locator.get<DailyChallengeCubit>()..init(),
      child: const DailyChallengeSheet(),
    ),
  );
}

class DailyChallengeSheet extends StatelessWidget {
  const DailyChallengeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<DailyChallengeCubit>();

    return BlocConsumer<DailyChallengeCubit, DailyChallengeState>(
      listener: (context, state) {
        if (state is DailyChallengeWon) {
          ConfettiOverlay.celebrate(
            context,
            title: 'You did it!',
            subtitle: 'All ${state.totalQuestions} answers correct 🏆',
            // ConfettiOverlay derives a soft card tint from this, so it needs a
            // light/warm accent (the other celebrations pass pastel category
            // colors). The saturated brand purple gave a dull grey-lavender card.
            accentColor: colorScheme.secondary,
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.9,
          child: Padding(
            padding: EdgeInsets.fromLTRB(Insets.i24, 0, Insets.i24, Insets.i24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: Insets.i8),
                    Expanded(
                      child: Text(
                        'Daily Challenge',
                        style: AppCss.bodySmallSemiBold.size(20).textColor(colorScheme.onSurface),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                Expanded(
                  child: switch (state) {
                    DailyChallengeInitial() || DailyChallengeLoading() => const LoadingWidget(),
                    DailyChallengeError() => _MessageView(message: state.message),
                    DailyChallengeQuestion() => _QuestionView(state: state, cubit: cubit),
                    DailyChallengeWon() => _WonView(state: state),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  final DailyChallengeQuestion state;
  final DailyChallengeCubit cubit;

  const _QuestionView({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final answered = state.selectedWordId != null;
    final isLastCorrect = answered && (state.isCorrect ?? false) && state.correctCount == state.totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          child: LinearProgressIndicator(
            value: state.correctCount / state.totalQuestions,
            minHeight: Sizes.s8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
        SizedBox(height: Insets.i8),
        Text(
          '${state.correctCount}/${state.totalQuestions} correct',
          style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
        SizedBox(height: Insets.i16),
        Text('Which word matches the sound?', style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface)),
        SizedBox(height: Insets.i16),
        Center(
          child: GestureDetector(
            onTap: cubit.replay,
            child: Container(
              width: Sizes.s64,
              height: Sizes.s64,
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.volume_up_rounded, color: colorScheme.onPrimary, size: Sizes.s28),
            ),
          ),
        ),
        SizedBox(height: Insets.i16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: state.options.length,
            itemBuilder: (context, index) => _OptionCard(
              word: state.options[index],
              state: state,
              onTap: answered ? null : () => cubit.selectAnswer(state.options[index]),
            ),
          ),
        ),
        if (answered) ...[
          SizedBox(height: Insets.i8),
          Center(
            child: Text(
              (state.isCorrect ?? false) ? 'Great job! ⭐' : "Oops! We'll try that one again 💪",
              style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface),
            ),
          ),
          SizedBox(height: Insets.i12),
          PrimaryButton(label: isLastCorrect ? 'Finish' : 'Next', onPressed: cubit.next),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final Word word;
  final DailyChallengeQuestion state;
  final VoidCallback? onTap;

  const _OptionCard({required this.word, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final answered = state.selectedWordId != null;
    final isSelected = state.selectedWordId == word.id;
    final isTarget = word.id == state.targetWord.id;

    Color background = colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    Color foreground = colorScheme.onSurface;
    if (answered && isSelected && !(state.isCorrect ?? false)) {
      background = colorScheme.errorContainer;
      foreground = colorScheme.onErrorContainer;
    } else if (answered && (isSelected || isTarget)) {
      // The correct card is revealed after a wrong answer too, so the child
      // still hears/sees the right pairing before it comes around again.
      background = colorScheme.tertiaryContainer;
      foreground = colorScheme.onTertiaryContainer;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Container(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.r16)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word.emoji, style: const TextStyle(fontSize: 36)),
            SizedBox(height: Insets.i8),
            Text(word.text, style: AppCss.bodySmallSemiBold.size(16).textColor(foreground)),
          ],
        ),
      ),
    );
  }
}

class _WonView extends StatelessWidget {
  final DailyChallengeWon state;

  const _WonView({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: const Text('🏆', style: TextStyle(fontSize: 96)),
              ),
              SizedBox(height: Insets.i16),
              Text('Challenge complete!', style: AppCss.h6.textColor(colorScheme.onSurface)),
              SizedBox(height: Insets.i8),
              Text(
                'You got all ${state.totalQuestions} right. See you tomorrow!',
                textAlign: TextAlign.center,
                style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        PrimaryButton(label: 'Done', trailingIcon: null, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  final String message;

  const _MessageView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📚', style: TextStyle(fontSize: 64)),
        SizedBox(height: Insets.i16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        SizedBox(height: Insets.i30),
        PrimaryButton(label: 'OK', trailingIcon: null, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

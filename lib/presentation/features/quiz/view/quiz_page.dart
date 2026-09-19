import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/presentation/common/confetti_overlay.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/primary_button.dart';
import 'package:vocab_app/presentation/features/quiz/viewmodel/quiz_cubit.dart';

class QuizPage extends StatelessWidget {
  final String categoryId;

  const QuizPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quizCubit = context.read<QuizCubit>();

    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizError) {
          showAlertDialog(context: context, body: state.message);
        }
        if (state is QuizFinished) {
          final isPerfect = state.correctCount == state.totalQuestions;
          ConfettiOverlay.celebrate(
            context,
            title: isPerfect ? 'Perfect score!' : 'Quiz complete!',
            subtitle: 'You got ${state.correctCount}/${state.totalQuestions} right 🎉',
            accentColor: state.category.colorHex.toColor(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Listen and choose', style: AppCss.bodySmallSemiBold.textColor(colorScheme.onSurface))),
          body: switch (state) {
            QuizInitial() || QuizLoading() => const LoadingWidget(),
            QuizError() => const SizedBox.shrink(),
            QuizQuestion() => _QuizQuestionView(state: state, quizCubit: quizCubit),
            QuizFinished() => _QuizFinishedView(state: state, quizCubit: quizCubit),
          },
        );
      },
    );
  }
}

class _QuizQuestionView extends StatelessWidget {
  final QuizQuestion state;
  final QuizCubit quizCubit;

  const _QuizQuestionView({required this.state, required this.quizCubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final answered = state.selectedWordId != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.i24, Insets.i8, Insets.i24, Insets.i24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            child: LinearProgressIndicator(
              value: state.questionNumber / state.totalQuestions,
              minHeight: Sizes.s8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          SizedBox(height: Insets.i8),
          Text(
            '${state.questionNumber}/${state.totalQuestions}',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          SizedBox(height: Insets.i20),
          Text('Which word matches the sound?', style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i24),
          Center(
            child: GestureDetector(
              onTap: quizCubit.replay,
              child: Container(
                width: Sizes.s80,
                height: Sizes.s80,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.volume_up_rounded, color: colorScheme.onPrimary, size: Sizes.s32),
              ),
            ),
          ),
          SizedBox(height: Insets.i30),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: state.options.length,
              itemBuilder: (context, index) => _OptionCard(
                word: state.options[index],
                state: state,
                onTap: answered ? null : () => quizCubit.selectAnswer(state.options[index]),
              ),
            ),
          ),
          if (answered) ...[
            SizedBox(height: Insets.i12),
            PrimaryButton(
              label: state.questionNumber == state.totalQuestions ? 'Finish' : 'Next',
              onPressed: quizCubit.next,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final Word word;
  final QuizQuestion state;
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
    if (answered && isSelected) {
      background = (state.isCorrect ?? false) ? colorScheme.tertiaryContainer : colorScheme.errorContainer;
      foreground = (state.isCorrect ?? false) ? colorScheme.onTertiaryContainer : colorScheme.onErrorContainer;
    } else if (answered && isTarget) {
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

class _QuizFinishedView extends StatelessWidget {
  final QuizFinished state;
  final QuizCubit quizCubit;

  const _QuizFinishedView({required this.state, required this.quizCubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(Insets.i24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          SizedBox(height: Insets.i16),
          Text('Great job!', style: AppCss.h5.bold.textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i8),
          Text(
            'You got ${state.correctCount} out of ${state.totalQuestions} right',
            textAlign: TextAlign.center,
            style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          SizedBox(height: Insets.i30),
          PrimaryButton(label: 'Try Again', trailingIcon: Icons.refresh_rounded, onPressed: quizCubit.restart),
          SizedBox(height: Insets.i12),
          PrimaryButton(
            label: 'Back to ${state.category.name}',
            trailingIcon: null,
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/stat_chip.dart';
import 'package:vocab_app/presentation/features/progress/viewmodel/progress_cubit.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<ProgressCubit, ProgressState>(
      listener: (context, state) {
        if (state is ProgressError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('My Progress', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
          body: state is ProgressLoading || state is ProgressInitial
              ? const LoadingWidget()
              : state is ProgressLoaded
                  ? _ProgressContent(state: state)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final ProgressLoaded state;

  const _ProgressContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = state.summary;

    return ListView(
      padding: EdgeInsets.all(Insets.i20),
      children: [
        Container(
          padding: EdgeInsets.all(Insets.i16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Row(
            children: [
              Container(
                width: Sizes.s48,
                height: Sizes.s48,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('🧒', style: TextStyle(fontSize: 24)),
              ),
              SizedBox(width: Insets.i12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Great job!', style: AppCss.bodyBaseSemibold.size(18).textColor(colorScheme.onPrimaryContainer)),
                    Text(
                      "You're learning so well!",
                      style: AppCss.captionSmall.textColor(colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Insets.i16),
        Row(
          children: [
            StatChip(
              emoji: '⭐',
              value: '${summary.wordsLearned}',
              label: 'Words Learned',
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
            SizedBox(width: Insets.i12),
            StatChip(
              emoji: '🔥',
              value: '${summary.dayStreak}',
              label: 'Day Streak',
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            SizedBox(width: Insets.i12),
            StatChip(
              emoji: '📚',
              value: '${summary.categoriesTouched}',
              label: 'Categories',
              backgroundColor: colorScheme.tertiaryContainer,
              foregroundColor: colorScheme.onTertiaryContainer,
            ),
          ],
        ),
        SizedBox(height: Insets.i24),
        Text('Recent Activity', style: AppCss.bodySmallSemiBold.size(18).textColor(colorScheme.onSurface)),
        SizedBox(height: Insets.i12),
        if (summary.recentActivity.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: Insets.i20),
            child: Text(
              'Open a flashcard or take a quiz to start your progress!',
              style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          )
        else
          ...summary.recentActivity.map((item) => Padding(
                padding: EdgeInsets.only(bottom: Insets.i12),
                child: Row(
                  children: [
                    Text(item.word.emoji, style: const TextStyle(fontSize: 28)),
                    SizedBox(width: Insets.i12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.word.text, style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface)),
                          Text(
                            ProgressRepository.relativeDayLabel(item.learnedAt),
                            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: colorScheme.tertiary),
                  ],
                ),
              )),
      ],
    );
  }
}

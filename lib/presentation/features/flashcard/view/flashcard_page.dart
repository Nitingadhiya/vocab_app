import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/presentation/common/confetti_overlay.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/pager_row.dart';
import 'package:vocab_app/presentation/features/flashcard/viewmodel/flashcard_cubit.dart';

class FlashcardPage extends StatelessWidget {
  final String categoryId;
  final String wordId;

  const FlashcardPage({super.key, required this.categoryId, required this.wordId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flashcardCubit = context.read<FlashcardCubit>();

    return BlocConsumer<FlashcardCubit, FlashcardState>(
      listener: (context, state) {
        if (state is FlashcardError) {
          showAlertDialog(context: context, body: state.message);
        }
        if (state is FlashcardLoaded && state.celebrateCategoryComplete) {
          ConfettiOverlay.celebrate(
            context,
            title: 'You finished ${state.category.name}!',
            subtitle: 'Amazing work! 🎉',
            accentColor: state.category.colorHex.toColor(),
          );
        }
        final challengeUpdate = state is FlashcardLoaded ? state.dailyChallengeUpdate : null;
        if (challengeUpdate != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(_challengeMessage(challengeUpdate))));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (state is FlashcardLoaded)
                IconButton(
                  onPressed: flashcardCubit.toggleFavorite,
                  icon: Icon(
                    state.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: colorScheme.secondary,
                  ),
                ),
            ],
          ),
          body: state is FlashcardLoading || state is FlashcardInitial
              ? const LoadingWidget()
              : state is FlashcardLoaded
                  ? _FlashcardContent(categoryId: categoryId, state: state)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

String _challengeMessage(DailyChallengeSummary summary) {
  const target = DailyChallengeRepository.minLearnedWords;
  if (summary.status == DailyChallengeStatus.available) {
    return '🎉 $target / $target words learned — Daily Challenge Unlocked! Play it from Home.';
  }
  final remaining = summary.wordsRemaining;
  return '🏆 ${summary.unlockProgress} / $target words learned — '
      '$remaining more ${remaining == 1 ? 'word' : 'words'} to unlock the Daily Challenge';
}

class _FlashcardContent extends StatelessWidget {
  final String categoryId;
  final FlashcardLoaded state;

  const _FlashcardContent({required this.categoryId, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final word = state.currentWord;
    final flashcardCubit = context.read<FlashcardCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.i24),
      child: Column(
        children: [
          const Spacer(),
          if (word.letter != null) ...[
            Text(word.letter!, style: AppCss.h1.bold.textColor(colorScheme.primary)),
            SizedBox(height: Insets.i12),
          ],
          Container(
            width: Sizes.s160,
            height: Sizes.s160,
            decoration: BoxDecoration(
              color: state.category.colorHex.toColor(),
              borderRadius: BorderRadius.circular(AppRadius.r24),
            ),
            alignment: Alignment.center,
            child: Text(word.emoji, style: const TextStyle(fontSize: 80)),
          ),
          SizedBox(height: Insets.i20),
          Text(word.text, style: AppCss.h5.bold.textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i24),
          GestureDetector(
            onTap: flashcardCubit.speakCurrent,
            child: Container(
              width: Sizes.s64,
              height: Sizes.s64,
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.volume_up_rounded, color: colorScheme.onPrimary, size: Sizes.s28),
            ),
          ),
          SizedBox(height: Insets.i12),
          Text(
            'Tap to hear the word',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const Spacer(flex: 2),
          PagerRow(
            currentIndex: state.currentIndex,
            itemCount: state.words.length,
            onGoTo: (index) => context.pushReplacement('/category/$categoryId/word/${state.words[index].id}'),
          ),
          SizedBox(height: Insets.i24),
        ],
      ),
    );
  }
}

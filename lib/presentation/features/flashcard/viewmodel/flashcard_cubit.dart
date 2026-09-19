import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;
  final DailyChallengeRepository dailyChallengeRepository;
  final TtsService ttsService;

  FlashcardCubit({
    required this.vocabRepository,
    required this.progressRepository,
    required this.dailyChallengeRepository,
    required this.ttsService,
  }) : super(FlashcardInitial());

  void init(String categoryId, String wordId) async {
    try {
      emit(FlashcardLoading());
      final category = await vocabRepository.getCategory(categoryId);
      final words = await vocabRepository.getWords(categoryId);
      final index = words.indexWhere((w) => w.id == wordId);

      if (index == -1) {
        emit(const FlashcardError(message: 'Word not found'));
        return;
      }

      final wasCategoryComplete = progressRepository.isCategoryComplete(words);
      final isNewlyLearned = !progressRepository.isWordLearned(wordId);
      await progressRepository.markWordLearned(wordId);
      final justCompletedCategory = !wasCategoryComplete && progressRepository.isCategoryComplete(words);
      final dailyChallengeUpdate = isNewlyLearned ? await _dailyChallengeUpdate() : null;

      emit(FlashcardLoaded(
        category: category,
        words: words,
        currentIndex: index,
        isFavorite: progressRepository.isFavorite(wordId),
        celebrateCategoryComplete: justCompletedCategory,
        dailyChallengeUpdate: dailyChallengeUpdate,
      ));

      speakCurrent();
    } catch (e) {
      emit(FlashcardError(message: e.toString()));
    }
  }

  /// The summary worth telling the child about after learning a new word:
  /// still working towards the unlock, or the word that just unlocked it.
  /// Null once the challenge is already unlocked/done — nothing new to say.
  Future<DailyChallengeSummary?> _dailyChallengeUpdate() async {
    final summary = await dailyChallengeRepository.getSummary();
    final justUnlocked = summary.status == DailyChallengeStatus.available &&
        summary.learnedWords == DailyChallengeRepository.minLearnedWords;
    return summary.status == DailyChallengeStatus.locked || justUnlocked ? summary : null;
  }

  void speakCurrent() {
    final current = state;
    if (current is FlashcardLoaded) {
      ttsService.speak(current.currentWord.text);
    }
  }

  void toggleFavorite() async {
    final current = state;
    if (current is! FlashcardLoaded) return;
    final isFavorite = await progressRepository.toggleFavorite(current.currentWord.id);
    emit(current.copyWith(isFavorite: isFavorite));
  }
}

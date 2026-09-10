import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;
  final TtsService ttsService;

  FlashcardCubit({
    required this.vocabRepository,
    required this.progressRepository,
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

      await progressRepository.markWordLearned(wordId);

      emit(FlashcardLoaded(
        category: category,
        words: words,
        currentIndex: index,
        isFavorite: progressRepository.isFavorite(wordId),
      ));

      speakCurrent();
    } catch (e) {
      emit(FlashcardError(message: e.toString()));
    }
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

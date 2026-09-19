import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'phonics_state.dart';

const _phonicsCategoryId = 'phonics';

/// Dedicated letter-sound practice: one big letter per screen, TTS speaks the
/// phonics sound (e.g. "kuh" for C) rather than the letter name or a word —
/// kept separate from [FlashcardCubit], which pairs a letter with a vocab word.
class PhonicsCubit extends Cubit<PhonicsState> {
  final VocabRepository vocabRepository;
  final TtsService ttsService;

  PhonicsCubit({required this.vocabRepository, required this.ttsService}) : super(PhonicsInitial());

  void init(String letterId) async {
    try {
      emit(PhonicsLoading());
      final category = await vocabRepository.getCategory(_phonicsCategoryId);
      final letters = await vocabRepository.getWords(_phonicsCategoryId);
      final index = letters.indexWhere((w) => w.id == letterId);

      if (index == -1) {
        emit(const PhonicsError(message: 'Letter not found'));
        return;
      }

      emit(PhonicsLoaded(category: category, letters: letters, currentIndex: index));
      speakCurrent();
    } catch (e) {
      emit(PhonicsError(message: e.toString()));
    }
  }

  void speakCurrent() {
    final current = state;
    if (current is PhonicsLoaded) {
      final letter = current.currentLetter;
      ttsService.speak(letter.phonicsSound ?? letter.text);
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'letter_tracing_state.dart';

const _phonicsCategoryId = 'phonics';

/// Drives the A-Z letter-tracing screen: which letter is loaded and whether
/// the child has finished tracing it. The actual touch sampling and
/// path-coverage scoring live in the tracing canvas widget (per-frame
/// gesture data doesn't belong in Bloc state) — this cubit only owns the
/// letter list/index (reusing the same `phonics` word list as
/// [PhonicsCubit]) and the coarse "is this letter done" result.
class LetterTracingCubit extends Cubit<LetterTracingState> {
  final VocabRepository vocabRepository;
  final TtsService ttsService;
  final PreferencesProvider preferencesProvider;

  LetterTracingCubit({
    required this.vocabRepository,
    required this.ttsService,
    required this.preferencesProvider,
  }) : super(LetterTracingInitial());

  void init(String letterId) async {
    try {
      emit(LetterTracingLoading());
      final category = await vocabRepository.getCategory(_phonicsCategoryId);
      final letters = await vocabRepository.getWords(_phonicsCategoryId);
      final index = letters.indexWhere((w) => w.id == letterId);

      if (index == -1) {
        emit(const LetterTracingError(message: 'Letter not found'));
        return;
      }

      emit(LetterTracingLoaded(category: category, letters: letters, currentIndex: index, isComplete: false, attempt: 0));
    } catch (e) {
      emit(LetterTracingError(message: e.toString()));
    }
  }

  /// Called by the tracing canvas once enough of the guide has been covered.
  void markComplete() async {
    final current = state;
    if (current is LetterTracingLoaded && !current.isComplete) {
      final before = preferencesProvider.getCompletedLetters();
      final isNewLetter = !before.contains(current.currentLetter.id);
      final after = {...before, current.currentLetter.id};
      await preferencesProvider.setCompletedLetters(after);
      final justFinishedAll = isNewLetter && current.letters.every((l) => after.contains(l.id));

      emit(current.copyWith(isComplete: true, celebrateAll: justFinishedAll));
      ttsService.speak('Great job!');
    }
  }

  void retry() {
    final current = state;
    if (current is LetterTracingLoaded) {
      emit(current.copyWith(isComplete: false, attempt: current.attempt + 1));
    }
  }
}

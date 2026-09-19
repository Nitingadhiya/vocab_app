import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'daily_challenge_state.dart';

/// "Listen and choose" quiz over words the child has already learned. A wrong
/// answer isn't final: that question goes to the back of the queue and comes
/// around again, so the challenge is only won once every question has been
/// answered correctly.
class DailyChallengeCubit extends Cubit<DailyChallengeState> {
  final DailyChallengeRepository dailyChallengeRepository;
  final TtsService ttsService;

  final Random _random = Random();

  static const int _maxOptions = 4;

  List<Word> _learnedWords = [];
  List<Word> _distractorPool = [];
  final Queue<Word> _pending = Queue();
  int _totalQuestions = 0;
  int _correctCount = 0;

  DailyChallengeCubit({required this.dailyChallengeRepository, required this.ttsService})
      : super(DailyChallengeInitial());

  void init() async {
    try {
      emit(DailyChallengeLoading());
      _learnedWords = await dailyChallengeRepository.getLearnedWords();
      _distractorPool = await dailyChallengeRepository.getDistractorPool();

      if (_learnedWords.length < DailyChallengeRepository.minLearnedWords) {
        emit(const DailyChallengeError(message: 'Learn a few more words, then come back for the challenge!'));
        return;
      }

      final questions = (List.of(_learnedWords)..shuffle(_random)).take(DailyChallengeRepository.maxQuestions);
      _pending
        ..clear()
        ..addAll(questions);
      _totalQuestions = _pending.length;
      _correctCount = 0;

      _emitQuestion();
    } catch (e) {
      emit(DailyChallengeError(message: e.toString()));
    }
  }

  void _emitQuestion() {
    final target = _pending.first;
    final options = [target, ..._pickDistractors(target)]..shuffle(_random);

    emit(DailyChallengeQuestion(
      correctCount: _correctCount,
      totalQuestions: _totalQuestions,
      targetWord: target,
      options: options,
    ));

    replay();
  }

  /// Prefers other learned words (so the options feel familiar) and tops up
  /// from the whole vocabulary. Deduped by text because different categories
  /// share words (e.g. the alphabet's "Apple" and food's "Apple"), which would
  /// otherwise put two identical-looking correct answers on screen.
  List<Word> _pickDistractors(Word target) {
    final learnedIds = _learnedWords.map((w) => w.id).toSet();
    final candidates = [
      ...(_learnedWords.where((w) => w.id != target.id).toList()..shuffle(_random)),
      ...(_distractorPool.where((w) => !learnedIds.contains(w.id)).toList()..shuffle(_random)),
    ];

    final seenTexts = {target.text.toLowerCase()};
    final picked = <Word>[];
    for (final word in candidates) {
      if (picked.length == _maxOptions - 1) break;
      if (seenTexts.add(word.text.toLowerCase())) picked.add(word);
    }
    return picked;
  }

  void replay() {
    final current = state;
    if (current is DailyChallengeQuestion) {
      ttsService.speak(current.targetWord.text);
    }
  }

  void selectAnswer(Word chosen) {
    final current = state;
    if (current is! DailyChallengeQuestion || current.selectedWordId != null) return;

    final isCorrect = chosen.text.toLowerCase() == current.targetWord.text.toLowerCase();
    if (isCorrect) {
      _correctCount++;
      _pending.removeFirst();
    } else {
      _pending.addLast(_pending.removeFirst());
    }

    emit(current.copyWith(correctCount: _correctCount, selectedWordId: chosen.id, isCorrect: isCorrect));

    // Persist as soon as the last answer lands, not when "Finish" is tapped,
    // so closing the sheet at that moment doesn't lose today's win.
    if (_pending.isEmpty) dailyChallengeRepository.markCompletedToday();
  }

  void next() {
    final current = state;
    if (current is! DailyChallengeQuestion || current.selectedWordId == null) return;

    if (_pending.isEmpty) {
      emit(DailyChallengeWon(totalQuestions: _totalQuestions));
    } else {
      _emitQuestion();
    }
  }

  @override
  Future<void> close() {
    ttsService.stop();
    return super.close();
  }
}

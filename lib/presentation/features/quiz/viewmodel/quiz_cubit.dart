import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;
  final TtsService ttsService;

  final Random _random = Random();

  String? _categoryId;
  Category? _category;
  List<Word> _categoryWords = [];
  List<Word> _questionWords = [];
  int _questionIndex = 0;
  int _correctCount = 0;

  static const int _maxQuestions = 8;
  static const int _maxOptions = 4;

  QuizCubit({
    required this.vocabRepository,
    required this.progressRepository,
    required this.ttsService,
  }) : super(QuizInitial());

  void init(String categoryId) async {
    try {
      emit(QuizLoading());
      _categoryId = categoryId;
      _category = await vocabRepository.getCategory(categoryId);
      _categoryWords = await vocabRepository.getWords(categoryId);

      if (_categoryWords.length < 2) {
        emit(const QuizError(message: 'This category needs more words for a quiz.'));
        return;
      }

      _questionWords = List.of(_categoryWords)..shuffle(_random);
      _questionWords = _questionWords.take(min(_maxQuestions, _questionWords.length)).toList();
      _questionIndex = 0;
      _correctCount = 0;

      _emitQuestion();
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  void restart() {
    final categoryId = _categoryId;
    if (categoryId != null) init(categoryId);
  }

  void _emitQuestion() {
    final target = _questionWords[_questionIndex];
    final optionCount = min(_maxOptions, _categoryWords.length);

    final distractorPool = _categoryWords.where((w) => w.id != target.id).toList()..shuffle(_random);
    final options = [target, ...distractorPool.take(optionCount - 1)]..shuffle(_random);

    emit(QuizQuestion(
      category: _category!,
      questionNumber: _questionIndex + 1,
      totalQuestions: _questionWords.length,
      targetWord: target,
      options: options,
    ));

    replay();
  }

  void replay() {
    final current = state;
    if (current is QuizQuestion) {
      ttsService.speak(current.targetWord.text);
    }
  }

  void selectAnswer(Word chosen) {
    final current = state;
    if (current is! QuizQuestion || current.selectedWordId != null) return;

    final isCorrect = chosen.id == current.targetWord.id;
    if (isCorrect) {
      _correctCount++;
      progressRepository.markWordLearned(current.targetWord.id);
    }

    emit(current.copyWith(selectedWordId: chosen.id, isCorrect: isCorrect));
  }

  void next() {
    final current = state;
    if (current is! QuizQuestion || current.selectedWordId == null) return;

    if (_questionIndex + 1 < _questionWords.length) {
      _questionIndex++;
      _emitQuestion();
    } else {
      emit(QuizFinished(
        category: _category!,
        correctCount: _correctCount,
        totalQuestions: _questionWords.length,
      ));
    }
  }
}

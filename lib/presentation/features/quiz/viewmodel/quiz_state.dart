part of 'quiz_cubit.dart';

sealed class QuizState extends Equatable {
  const QuizState();
}

final class QuizInitial extends QuizState {
  @override
  List<Object?> get props => [];
}

final class QuizLoading extends QuizState {
  @override
  List<Object?> get props => [];
}

final class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class QuizQuestion extends QuizState {
  final Category category;
  final int questionNumber;
  final int totalQuestions;
  final Word targetWord;
  final List<Word> options;
  final String? selectedWordId;
  final bool? isCorrect;

  const QuizQuestion({
    required this.category,
    required this.questionNumber,
    required this.totalQuestions,
    required this.targetWord,
    required this.options,
    this.selectedWordId,
    this.isCorrect,
  });

  QuizQuestion copyWith({String? selectedWordId, bool? isCorrect}) {
    return QuizQuestion(
      category: category,
      questionNumber: questionNumber,
      totalQuestions: totalQuestions,
      targetWord: targetWord,
      options: options,
      selectedWordId: selectedWordId ?? this.selectedWordId,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  List<Object?> get props =>
      [category, questionNumber, totalQuestions, targetWord, options, selectedWordId, isCorrect];
}

final class QuizFinished extends QuizState {
  final Category category;
  final int correctCount;
  final int totalQuestions;

  const QuizFinished({required this.category, required this.correctCount, required this.totalQuestions});

  @override
  List<Object?> get props => [category, correctCount, totalQuestions];
}

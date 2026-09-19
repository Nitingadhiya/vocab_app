part of 'daily_challenge_cubit.dart';

sealed class DailyChallengeState extends Equatable {
  const DailyChallengeState();
}

final class DailyChallengeInitial extends DailyChallengeState {
  @override
  List<Object?> get props => [];
}

final class DailyChallengeLoading extends DailyChallengeState {
  @override
  List<Object?> get props => [];
}

final class DailyChallengeError extends DailyChallengeState {
  final String message;

  const DailyChallengeError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class DailyChallengeQuestion extends DailyChallengeState {
  /// Questions answered correctly so far — drives the progress bar.
  final int correctCount;
  final int totalQuestions;
  final Word targetWord;
  final List<Word> options;
  final String? selectedWordId;
  final bool? isCorrect;

  const DailyChallengeQuestion({
    required this.correctCount,
    required this.totalQuestions,
    required this.targetWord,
    required this.options,
    this.selectedWordId,
    this.isCorrect,
  });

  DailyChallengeQuestion copyWith({int? correctCount, String? selectedWordId, bool? isCorrect}) {
    return DailyChallengeQuestion(
      correctCount: correctCount ?? this.correctCount,
      totalQuestions: totalQuestions,
      targetWord: targetWord,
      options: options,
      selectedWordId: selectedWordId ?? this.selectedWordId,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  List<Object?> get props => [correctCount, totalQuestions, targetWord, options, selectedWordId, isCorrect];
}

/// Every question has been answered correctly.
final class DailyChallengeWon extends DailyChallengeState {
  final int totalQuestions;

  const DailyChallengeWon({required this.totalQuestions});

  @override
  List<Object?> get props => [totalQuestions];
}

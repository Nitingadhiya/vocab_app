part of 'letter_tracing_cubit.dart';

sealed class LetterTracingState extends Equatable {
  const LetterTracingState();
}

final class LetterTracingInitial extends LetterTracingState {
  @override
  List<Object> get props => [];
}

final class LetterTracingLoading extends LetterTracingState {
  @override
  List<Object> get props => [];
}

final class LetterTracingError extends LetterTracingState {
  final String message;

  const LetterTracingError({required this.message});

  @override
  List<Object> get props => [message];
}

final class LetterTracingLoaded extends LetterTracingState {
  final Category category;
  final List<Word> letters;
  final int currentIndex;
  final bool isComplete;

  /// True for exactly the one emit where this letter completion was the
  /// last of all 26 still needed — tells the page to fire the big
  /// confetti celebration instead of (in addition to) the small toast.
  final bool celebrateAll;

  /// Bumped by [LetterTracingCubit.retry]; used as part of the tracing
  /// canvas's widget key so a retry (or moving to a new letter, since
  /// [currentIndex] also changes) throws away the in-progress ink/coverage
  /// state instead of carrying it over.
  final int attempt;

  const LetterTracingLoaded({
    required this.category,
    required this.letters,
    required this.currentIndex,
    required this.isComplete,
    required this.attempt,
    this.celebrateAll = false,
  });

  Word get currentLetter => letters[currentIndex];

  LetterTracingLoaded copyWith({bool? isComplete, int? attempt, bool? celebrateAll}) {
    return LetterTracingLoaded(
      category: category,
      letters: letters,
      currentIndex: currentIndex,
      isComplete: isComplete ?? this.isComplete,
      attempt: attempt ?? this.attempt,
      celebrateAll: celebrateAll ?? false,
    );
  }

  @override
  List<Object> get props => [category, letters, currentIndex, isComplete, attempt, celebrateAll];
}

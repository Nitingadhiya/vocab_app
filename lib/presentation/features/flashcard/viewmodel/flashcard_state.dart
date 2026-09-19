part of 'flashcard_cubit.dart';

sealed class FlashcardState extends Equatable {
  const FlashcardState();
}

final class FlashcardInitial extends FlashcardState {
  @override
  List<Object> get props => [];
}

final class FlashcardLoading extends FlashcardState {
  @override
  List<Object> get props => [];
}

final class FlashcardError extends FlashcardState {
  final String message;

  const FlashcardError({required this.message});

  @override
  List<Object> get props => [message];
}

final class FlashcardLoaded extends FlashcardState {
  final Category category;
  final List<Word> words;
  final int currentIndex;
  final bool isFavorite;

  /// True for exactly the one emit where the word just loaded was the last
  /// of the category still needed — tells the page to fire the big confetti
  /// celebration for finishing the whole category.
  final bool celebrateCategoryComplete;

  /// Set for exactly the one emit where opening this card newly learned a word
  /// that moved the daily-challenge unlock forward (or completed it) — the
  /// page turns it into an "n / 3 words learned" toast. Null otherwise.
  final DailyChallengeSummary? dailyChallengeUpdate;

  const FlashcardLoaded({
    required this.category,
    required this.words,
    required this.currentIndex,
    required this.isFavorite,
    this.celebrateCategoryComplete = false,
    this.dailyChallengeUpdate,
  });

  Word get currentWord => words[currentIndex];

  FlashcardLoaded copyWith({bool? isFavorite}) {
    return FlashcardLoaded(
      category: category,
      words: words,
      currentIndex: currentIndex,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props =>
      [category, words, currentIndex, isFavorite, celebrateCategoryComplete, dailyChallengeUpdate];
}

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

  const FlashcardLoaded({
    required this.category,
    required this.words,
    required this.currentIndex,
    required this.isFavorite,
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
  List<Object> get props => [category, words, currentIndex, isFavorite];
}

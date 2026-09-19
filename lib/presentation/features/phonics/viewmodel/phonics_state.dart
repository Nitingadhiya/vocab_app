part of 'phonics_cubit.dart';

sealed class PhonicsState extends Equatable {
  const PhonicsState();
}

final class PhonicsInitial extends PhonicsState {
  @override
  List<Object> get props => [];
}

final class PhonicsLoading extends PhonicsState {
  @override
  List<Object> get props => [];
}

final class PhonicsError extends PhonicsState {
  final String message;

  const PhonicsError({required this.message});

  @override
  List<Object> get props => [message];
}

final class PhonicsLoaded extends PhonicsState {
  final Category category;
  final List<Word> letters;
  final int currentIndex;

  const PhonicsLoaded({
    required this.category,
    required this.letters,
    required this.currentIndex,
  });

  Word get currentLetter => letters[currentIndex];

  @override
  List<Object> get props => [category, letters, currentIndex];
}

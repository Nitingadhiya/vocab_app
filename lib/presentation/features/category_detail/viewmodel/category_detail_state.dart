part of 'category_detail_cubit.dart';

sealed class CategoryDetailState extends Equatable {
  const CategoryDetailState();
}

final class CategoryDetailInitial extends CategoryDetailState {
  @override
  List<Object> get props => [];
}

final class CategoryDetailLoading extends CategoryDetailState {
  @override
  List<Object> get props => [];
}

final class CategoryDetailError extends CategoryDetailState {
  final String message;

  const CategoryDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

final class CategoryDetailLoaded extends CategoryDetailState {
  final Category category;
  final List<Word> words;
  final Set<String> learnedWordIds;
  final DailyChallengeSummary dailyChallenge;

  const CategoryDetailLoaded({
    required this.category,
    required this.words,
    required this.learnedWordIds,
    required this.dailyChallenge,
  });

  @override
  List<Object> get props => [category, words, learnedWordIds, dailyChallenge];
}

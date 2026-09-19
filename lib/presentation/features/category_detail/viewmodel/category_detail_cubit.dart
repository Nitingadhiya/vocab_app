import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';

part 'category_detail_state.dart';

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;
  final DailyChallengeRepository dailyChallengeRepository;

  late final StreamSubscription<void> _learnedWordsSubscription;

  CategoryDetailCubit({
    required this.vocabRepository,
    required this.progressRepository,
    required this.dailyChallengeRepository,
  }) : super(CategoryDetailInitial()) {
    // Flashcards are opened on top of this page, so a word learned there has
    // to show up here (✓ + daily-challenge count) without a manual reload.
    _learnedWordsSubscription = progressRepository.learnedWordsChanged.listen((_) => _refreshProgress());
  }

  void init(String categoryId) async {
    try {
      emit(CategoryDetailLoading());
      final category = await vocabRepository.getCategory(categoryId);
      final words = await vocabRepository.getWords(categoryId);
      emit(CategoryDetailLoaded(
        category: category,
        words: words,
        learnedWordIds: progressRepository.getLearnedWordIds(),
        dailyChallenge: await dailyChallengeRepository.getSummary(),
      ));
    } catch (e) {
      emit(CategoryDetailError(message: e.toString()));
    }
  }

  Future<void> _refreshProgress() async {
    if (state is! CategoryDetailLoaded) return;
    final summary = await dailyChallengeRepository.getSummary();
    final current = state;
    if (isClosed || current is! CategoryDetailLoaded) return;
    emit(CategoryDetailLoaded(
      category: current.category,
      words: current.words,
      learnedWordIds: progressRepository.getLearnedWordIds(),
      dailyChallenge: summary,
    ));
  }

  @override
  Future<void> close() {
    _learnedWordsSubscription.cancel();
    return super.close();
  }
}

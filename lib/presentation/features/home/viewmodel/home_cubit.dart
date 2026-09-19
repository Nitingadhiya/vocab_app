import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VocabRepository vocabRepository;
  final PreferencesProvider preferencesProvider;
  final DailyChallengeRepository dailyChallengeRepository;

  bool _launchPromptHandled = false;
  late final StreamSubscription<void> _learnedWordsSubscription;

  HomeCubit({
    required this.vocabRepository,
    required this.preferencesProvider,
    required this.dailyChallengeRepository,
    required ProgressRepository progressRepository,
  }) : super(HomeInitial()) {
    // Keep the daily-challenge card live as words get learned elsewhere in
    // the app, so "n / 3 words learned" never lags behind what the child did.
    _learnedWordsSubscription = progressRepository.learnedWordsChanged.listen((_) => refreshDailyChallenge());
  }

  void init() async {
    try {
      emit(HomeLoading());
      final categories = await vocabRepository.getCategoriesWithWordCounts();
      final dailyChallenge = await dailyChallengeRepository.getSummary();
      emit(HomeLoaded(
        childName: preferencesProvider.getChildName(),
        categories: categories,
        dailyChallenge: dailyChallenge,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Re-reads only the daily-challenge status (e.g. after the sheet closes),
  /// avoiding the full-screen spinner that [init] shows.
  Future<void> refreshDailyChallenge() async {
    if (state is! HomeLoaded) return;
    final summary = await dailyChallengeRepository.getSummary();
    // Re-read the state after the await: init() may have replaced it meanwhile.
    final current = state;
    if (isClosed || current is! HomeLoaded) return;
    emit(current.copyWith(dailyChallenge: summary));
  }

  /// True at most once per app launch, and only while today's challenge is
  /// still waiting to be played — the caller shows the challenge sheet.
  bool takeLaunchPrompt() {
    if (_launchPromptHandled) return false;
    final current = state;
    if (current is! HomeLoaded) return false;
    _launchPromptHandled = true;
    return current.dailyChallenge.status == DailyChallengeStatus.available;
  }

  @override
  Future<void> close() {
    _learnedWordsSubscription.cancel();
    return super.close();
  }
}

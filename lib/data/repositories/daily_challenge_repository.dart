import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

enum DailyChallengeStatus {
  /// Not enough learned words yet to build a challenge from.
  locked,
  available,
  completedToday,
}

/// Where the child stands with today's challenge: its status plus how many
/// words they've learned so far (the unlock requirement).
class DailyChallengeSummary extends Equatable {
  final DailyChallengeStatus status;
  final int learnedWords;

  const DailyChallengeSummary({required this.status, required this.learnedWords});

  /// [learnedWords] capped at the unlock target, so the UI reads "3 / 3"
  /// rather than "17 / 3" once the child has learned more than enough.
  int get unlockProgress => min(learnedWords, DailyChallengeRepository.minLearnedWords);

  int get wordsRemaining => DailyChallengeRepository.minLearnedWords - unlockProgress;

  @override
  List<Object?> get props => [status, learnedWords];
}

/// Decides whether today's daily challenge can be played and remembers when it
/// was last won. Questions are only ever built from words the child has
/// already opened or learned (see [ProgressRepository.markWordLearned]).
class DailyChallengeRepository {
  static const int maxQuestions = 6;
  static const int minLearnedWords = 3;

  /// Phonics entries are bare letters with a 🔊 placeholder emoji, which makes
  /// for meaningless "pick the matching picture" questions, so they neither
  /// count towards the unlock nor appear in the challenge.
  static const String excludedCategoryId = 'phonics';

  final PreferencesProvider preferencesProvider;
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;

  DailyChallengeRepository({
    required this.preferencesProvider,
    required this.vocabRepository,
    required this.progressRepository,
  });

  Future<List<Word>> getLearnedWords() async {
    final learnedIds = progressRepository.getLearnedWordIds();
    final words = await vocabRepository.getAllWords();
    return words.where((w) => w.categoryId != excludedCategoryId && learnedIds.contains(w.id)).toList();
  }

  /// Every word usable as a wrong-answer option, learned or not.
  Future<List<Word>> getDistractorPool() async {
    final words = await vocabRepository.getAllWords();
    return words.where((w) => w.categoryId != excludedCategoryId).toList();
  }

  bool get isCompletedToday => preferencesProvider.getDailyChallengeDoneOn() == _dayKey(DateTime.now());

  Future<void> markCompletedToday() => preferencesProvider.setDailyChallengeDoneOn(_dayKey(DateTime.now()));

  Future<DailyChallengeSummary> getSummary() async {
    final learnedCount = (await getLearnedWords()).length;
    final status = isCompletedToday
        ? DailyChallengeStatus.completedToday
        : learnedCount >= minLearnedWords
            ? DailyChallengeStatus.available
            : DailyChallengeStatus.locked;
    return DailyChallengeSummary(status: status, learnedWords: learnedCount);
  }

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

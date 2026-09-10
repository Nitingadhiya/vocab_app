import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

class RecentActivityItem {
  final Word word;
  final DateTime learnedAt;

  const RecentActivityItem({required this.word, required this.learnedAt});
}

class ProgressSummary {
  final int wordsLearned;
  final int dayStreak;
  final int categoriesTouched;
  final List<RecentActivityItem> recentActivity;

  const ProgressSummary({
    required this.wordsLearned,
    required this.dayStreak,
    required this.categoriesTouched,
    required this.recentActivity,
  });

  static const empty = ProgressSummary(
    wordsLearned: 0,
    dayStreak: 0,
    categoriesTouched: 0,
    recentActivity: [],
  );
}

/// Tracks and derives the child's learning progress, persisted locally.
class ProgressRepository {
  final PreferencesProvider preferencesProvider;

  ProgressRepository({required this.preferencesProvider});

  Future<void> markWordLearned(String wordId) async {
    final learned = preferencesProvider.getLearnedWords();
    if (learned.containsKey(wordId)) return;
    learned[wordId] = DateTime.now().toIso8601String();
    await preferencesProvider.setLearnedWords(learned);
  }

  bool isWordLearned(String wordId) => preferencesProvider.getLearnedWords().containsKey(wordId);

  Set<String> getFavorites() => preferencesProvider.getFavorites();

  bool isFavorite(String wordId) => getFavorites().contains(wordId);

  Future<bool> toggleFavorite(String wordId) async {
    final favorites = getFavorites();
    final nowFavorite = !favorites.contains(wordId);
    if (nowFavorite) {
      favorites.add(wordId);
    } else {
      favorites.remove(wordId);
    }
    await preferencesProvider.setFavorites(favorites);
    return nowFavorite;
  }

  ProgressSummary getSummary(List<Word> allWords) {
    final learned = preferencesProvider.getLearnedWords();
    if (learned.isEmpty) return ProgressSummary.empty;

    final wordsById = {for (final w in allWords) w.id: w};

    final entries = learned.entries
        .where((e) => wordsById.containsKey(e.key))
        .map((e) => RecentActivityItem(word: wordsById[e.key]!, learnedAt: DateTime.parse(e.value)))
        .toList()
      ..sort((a, b) => b.learnedAt.compareTo(a.learnedAt));

    final categoriesTouched = entries.map((e) => e.word.categoryId).toSet().length;
    final dayStreak = _computeStreak(entries.map((e) => e.learnedAt).toList());

    return ProgressSummary(
      wordsLearned: entries.length,
      dayStreak: dayStreak,
      categoriesTouched: categoriesTouched,
      recentActivity: entries.take(10).toList(),
    );
  }

  int _computeStreak(List<DateTime> timestamps) {
    final days = timestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var cursor = todayDate;
    if (days.first != todayDate) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (days.first != yesterday) return 0;
      cursor = yesterday;
    }

    var streak = 0;
    for (final day in days) {
      if (day == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day.isBefore(cursor)) {
        break;
      }
    }
    return streak;
  }

  static String relativeDayLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}

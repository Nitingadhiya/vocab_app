import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] — the only place that knows the keys.
class PreferencesProvider {
  final SharedPreferences prefs;

  PreferencesProvider({required this.prefs});

  static const _kHasOnboarded = 'has_onboarded';
  static const _kLearnedWords = 'learned_words_v1'; // {wordId: isoTimestamp}
  static const _kFavorites = 'favorite_words_v1';
  static const _kCompletedLetters = 'completed_letters_v1';
  static const _kAudioEnabled = 'audio_enabled';
  static const _kThemeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _kChildName = 'child_name';
  static const _kDailyChallengeDoneOn = 'daily_challenge_done_on_v1'; // 'yyyy-MM-dd' (local date)

  bool getHasOnboarded() => prefs.getBool(_kHasOnboarded) ?? false;
  Future<void> setHasOnboarded(bool value) => prefs.setBool(_kHasOnboarded, value);

  Map<String, String> getLearnedWords() {
    final raw = prefs.getString(_kLearnedWords);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> setLearnedWords(Map<String, String> value) => prefs.setString(_kLearnedWords, jsonEncode(value));

  Set<String> getFavorites() => (prefs.getStringList(_kFavorites) ?? const []).toSet();
  Future<void> setFavorites(Set<String> value) => prefs.setStringList(_kFavorites, value.toList());

  Set<String> getCompletedLetters() => (prefs.getStringList(_kCompletedLetters) ?? const []).toSet();
  Future<void> setCompletedLetters(Set<String> value) => prefs.setStringList(_kCompletedLetters, value.toList());

  bool getAudioEnabled() => prefs.getBool(_kAudioEnabled) ?? true;
  Future<void> setAudioEnabled(bool value) => prefs.setBool(_kAudioEnabled, value);

  String getThemeMode() => prefs.getString(_kThemeMode) ?? 'light';
  Future<void> setThemeMode(String value) => prefs.setString(_kThemeMode, value);

  String getChildName() => prefs.getString(_kChildName) ?? 'Little Learner';
  Future<void> setChildName(String value) => prefs.setString(_kChildName, value);

  String? getDailyChallengeDoneOn() => prefs.getString(_kDailyChallengeDoneOn);
  Future<void> setDailyChallengeDoneOn(String value) => prefs.setString(_kDailyChallengeDoneOn, value);
}

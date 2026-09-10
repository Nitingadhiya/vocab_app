import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

class AppState extends Equatable {
  final ThemeMode themeMode;
  final bool audioEnabled;

  const AppState({required this.themeMode, required this.audioEnabled});

  AppState copyWith({ThemeMode? themeMode, bool? audioEnabled}) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      audioEnabled: audioEnabled ?? this.audioEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, audioEnabled];
}

/// App-wide settings (theme + audio) shared across every feature.
class AppCubit extends Cubit<AppState> {
  final PreferencesProvider preferencesProvider;

  AppCubit({required this.preferencesProvider})
      : super(AppState(
          themeMode: _modeFromString(preferencesProvider.getThemeMode()),
          audioEnabled: preferencesProvider.getAudioEnabled(),
        ));

  static ThemeMode _modeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await preferencesProvider.setThemeMode(_modeToString(mode));
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAudioEnabled(bool enabled) async {
    await preferencesProvider.setAudioEnabled(enabled);
    emit(state.copyWith(audioEnabled: enabled));
  }
}

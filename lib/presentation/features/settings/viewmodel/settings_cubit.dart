import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesProvider preferencesProvider;

  SettingsCubit({required this.preferencesProvider}) : super(SettingsInitial());

  void init() {
    emit(SettingsLoaded(childName: preferencesProvider.getChildName()));
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final PreferencesProvider preferencesProvider;

  OnboardingCubit({required this.preferencesProvider}) : super(OnboardingInitial());

  Future<void> getStarted() async {
    await preferencesProvider.setHasOnboarded(true);
    emit(OnboardingComplete());
  }
}

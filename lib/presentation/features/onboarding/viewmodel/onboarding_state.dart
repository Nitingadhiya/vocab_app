part of 'onboarding_cubit.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  @override
  List<Object> get props => [];
}

final class OnboardingComplete extends OnboardingState {
  @override
  List<Object> get props => [];
}

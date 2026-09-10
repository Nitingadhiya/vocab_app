part of 'progress_cubit.dart';

sealed class ProgressState extends Equatable {
  const ProgressState();
}

final class ProgressInitial extends ProgressState {
  @override
  List<Object> get props => [];
}

final class ProgressLoading extends ProgressState {
  @override
  List<Object> get props => [];
}

final class ProgressError extends ProgressState {
  final String message;

  const ProgressError({required this.message});

  @override
  List<Object> get props => [message];
}

final class ProgressLoaded extends ProgressState {
  final String childName;
  final ProgressSummary summary;

  const ProgressLoaded({required this.childName, required this.summary});

  @override
  List<Object> get props => [childName, summary];
}

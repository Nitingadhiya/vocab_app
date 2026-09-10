part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}

final class HomeLoaded extends HomeState {
  final String childName;
  final List<CategoryWithCount> categories;

  const HomeLoaded({required this.childName, required this.categories});

  @override
  List<Object> get props => [childName, categories];
}

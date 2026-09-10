part of 'library_cubit.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();
}

final class LibraryInitial extends LibraryState {
  @override
  List<Object> get props => [];
}

final class LibraryLoading extends LibraryState {
  @override
  List<Object> get props => [];
}

final class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object> get props => [message];
}

final class LibraryLoaded extends LibraryState {
  final List<CategoryWithCount> categories;

  const LibraryLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

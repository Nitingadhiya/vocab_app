import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final VocabRepository vocabRepository;

  LibraryCubit({required this.vocabRepository}) : super(LibraryInitial());

  void init() async {
    try {
      emit(LibraryLoading());
      final categories = await vocabRepository.getCategoriesWithWordCounts();
      emit(LibraryLoaded(categories: categories));
    } catch (e) {
      emit(LibraryError(message: e.toString()));
    }
  }
}

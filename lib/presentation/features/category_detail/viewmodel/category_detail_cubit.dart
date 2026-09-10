import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';

part 'category_detail_state.dart';

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  final VocabRepository vocabRepository;

  CategoryDetailCubit({required this.vocabRepository}) : super(CategoryDetailInitial());

  void init(String categoryId) async {
    try {
      emit(CategoryDetailLoading());
      final category = await vocabRepository.getCategory(categoryId);
      final words = await vocabRepository.getWords(categoryId);
      emit(CategoryDetailLoaded(category: category, words: words));
    } catch (e) {
      emit(CategoryDetailError(message: e.toString()));
    }
  }
}

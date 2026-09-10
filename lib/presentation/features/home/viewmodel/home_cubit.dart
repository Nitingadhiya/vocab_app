import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VocabRepository vocabRepository;
  final PreferencesProvider preferencesProvider;

  HomeCubit({required this.vocabRepository, required this.preferencesProvider}) : super(HomeInitial());

  void init() async {
    try {
      emit(HomeLoading());
      final categories = await vocabRepository.getCategoriesWithWordCounts();
      emit(HomeLoaded(childName: preferencesProvider.getChildName(), categories: categories));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}

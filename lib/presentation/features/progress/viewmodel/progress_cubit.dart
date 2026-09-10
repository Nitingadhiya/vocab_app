import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;
  final PreferencesProvider preferencesProvider;

  ProgressCubit({
    required this.vocabRepository,
    required this.progressRepository,
    required this.preferencesProvider,
  }) : super(ProgressInitial());

  void init() async {
    try {
      emit(ProgressLoading());
      final allWords = await vocabRepository.getAllWords();
      final summary = progressRepository.getSummary(allWords);
      emit(ProgressLoaded(childName: preferencesProvider.getChildName(), summary: summary));
    } catch (e) {
      emit(ProgressError(message: e.toString()));
    }
  }
}

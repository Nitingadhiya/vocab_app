import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';
import 'package:vocab_app/data/sources/local/vocab_local_data_source.dart';
import 'package:vocab_app/presentation/app/viewmodel/app_cubit.dart';
import 'package:vocab_app/presentation/features/category_detail/viewmodel/category_detail_cubit.dart';
import 'package:vocab_app/presentation/features/daily_challenge/viewmodel/daily_challenge_cubit.dart';
import 'package:vocab_app/presentation/features/flashcard/viewmodel/flashcard_cubit.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';
import 'package:vocab_app/presentation/features/library/viewmodel/library_cubit.dart';
import 'package:vocab_app/presentation/features/letter_tracing/viewmodel/letter_tracing_cubit.dart';
import 'package:vocab_app/presentation/features/onboarding/viewmodel/onboarding_cubit.dart';
import 'package:vocab_app/presentation/features/phonics/viewmodel/phonics_cubit.dart';
import 'package:vocab_app/presentation/features/progress/viewmodel/progress_cubit.dart';
import 'package:vocab_app/presentation/features/quiz/viewmodel/quiz_cubit.dart';
import 'package:vocab_app/presentation/features/settings/viewmodel/settings_cubit.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => sharedPreferences);

  // Sources
  locator.registerLazySingleton(() => VocabLocalDataSource());
  locator.registerLazySingleton(() => PreferencesProvider(prefs: locator<SharedPreferences>()));
  locator.registerLazySingleton(() => TtsService());

  // Repositories
  locator.registerLazySingleton(() => VocabRepository(localDataSource: locator<VocabLocalDataSource>()));
  locator.registerLazySingleton(() => ProgressRepository(preferencesProvider: locator<PreferencesProvider>()));
  locator.registerLazySingleton(() => DailyChallengeRepository(
        preferencesProvider: locator<PreferencesProvider>(),
        vocabRepository: locator<VocabRepository>(),
        progressRepository: locator<ProgressRepository>(),
      ));

  // App-wide
  locator.registerLazySingleton(() => AppCubit(preferencesProvider: locator<PreferencesProvider>()));

  // Bottom-nav tab ViewModels (singletons so the shell can refresh them without
  // BuildContext scoping — see BottomNavShell).
  locator.registerLazySingleton(() => HomeCubit(
        vocabRepository: locator<VocabRepository>(),
        preferencesProvider: locator<PreferencesProvider>(),
        dailyChallengeRepository: locator<DailyChallengeRepository>(),
        progressRepository: locator<ProgressRepository>(),
      ));
  locator.registerLazySingleton(() => LibraryCubit(vocabRepository: locator<VocabRepository>()));
  locator.registerLazySingleton(() => ProgressCubit(
        vocabRepository: locator<VocabRepository>(),
        progressRepository: locator<ProgressRepository>(),
        preferencesProvider: locator<PreferencesProvider>(),
      ));

  // Factory Features
  locator.registerFactory(() => OnboardingCubit(preferencesProvider: locator<PreferencesProvider>()));
  locator.registerFactory(() => CategoryDetailCubit(
        vocabRepository: locator<VocabRepository>(),
        progressRepository: locator<ProgressRepository>(),
        dailyChallengeRepository: locator<DailyChallengeRepository>(),
      ));
  locator.registerFactory(() => FlashcardCubit(
        vocabRepository: locator<VocabRepository>(),
        progressRepository: locator<ProgressRepository>(),
        dailyChallengeRepository: locator<DailyChallengeRepository>(),
        ttsService: locator<TtsService>(),
      ));
  locator.registerFactory(() => PhonicsCubit(
        vocabRepository: locator<VocabRepository>(),
        ttsService: locator<TtsService>(),
      ));
  locator.registerFactory(() => LetterTracingCubit(
        vocabRepository: locator<VocabRepository>(),
        ttsService: locator<TtsService>(),
        preferencesProvider: locator<PreferencesProvider>(),
      ));
  locator.registerFactory(() => QuizCubit(
        vocabRepository: locator<VocabRepository>(),
        progressRepository: locator<ProgressRepository>(),
        ttsService: locator<TtsService>(),
      ));
  locator.registerFactory(() => DailyChallengeCubit(
        dailyChallengeRepository: locator<DailyChallengeRepository>(),
        ttsService: locator<TtsService>(),
      ));
  locator.registerFactory(() => SettingsCubit(preferencesProvider: locator<PreferencesProvider>()));
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_app/core/theme/theme.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/data/repositories/progress_repository.dart';
import 'package:vocab_app/data/repositories/vocab_repository.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';
import 'package:vocab_app/data/sources/local/tts_service.dart';
import 'package:vocab_app/data/sources/local/vocab_local_data_source.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/features/category_detail/view/category_detail_page.dart';
import 'package:vocab_app/presentation/features/category_detail/viewmodel/category_detail_cubit.dart';
import 'package:vocab_app/presentation/features/daily_challenge/view/daily_challenge_sheet.dart';
import 'package:vocab_app/presentation/features/daily_challenge/viewmodel/daily_challenge_cubit.dart';
import 'package:vocab_app/presentation/features/flashcard/viewmodel/flashcard_cubit.dart';
import 'package:vocab_app/presentation/features/home/view/home_page.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';

class _FakeTts implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}

class _Fixture {
  final PreferencesProvider prefs;
  final VocabRepository vocab;
  final ProgressRepository progress;
  final DailyChallengeRepository repository;

  _Fixture._(this.prefs, this.vocab, this.progress, this.repository);

  static Future<_Fixture> create({List<String> learnedIds = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesProvider(prefs: await SharedPreferences.getInstance());
    final vocab = VocabRepository(localDataSource: VocabLocalDataSource());
    final progress = ProgressRepository(preferencesProvider: prefs);
    for (final id in learnedIds) {
      await progress.markWordLearned(id);
    }
    final repository = DailyChallengeRepository(
      preferencesProvider: prefs,
      vocabRepository: vocab,
      progressRepository: progress,
    );
    return _Fixture._(prefs, vocab, progress, repository);
  }
}

/// Real word ids from the bundled JSON, so the tests don't hard-code a naming scheme.
Future<List<String>> _learnedIds(_Fixture f, int count) async {
  final words = await f.vocab.getAllWords();
  return words.where((w) => w.categoryId != 'phonics').take(count).map((w) => w.id).toList();
}

void _usePhoneSurface(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyChallengeRepository', () {
    test('is locked until enough words are learned', () async {
      var f = await _Fixture.create();
      expect((await f.repository.getSummary()).status, DailyChallengeStatus.locked);

      f = await _Fixture.create();
      final ids = await _learnedIds(f, DailyChallengeRepository.minLearnedWords - 1);
      for (final id in ids) {
        await f.progress.markWordLearned(id);
      }
      expect((await f.repository.getSummary()).status, DailyChallengeStatus.locked);

      await f.progress.markWordLearned((await _learnedIds(f, 3)).last);
      expect((await f.repository.getSummary()).status, DailyChallengeStatus.available);
    });

    test('phonics letters never count as learned words', () async {
      final f = await _Fixture.create();
      final phonics = (await f.vocab.getWords('phonics')).take(5);
      for (final w in phonics) {
        await f.progress.markWordLearned(w.id);
      }
      expect(await f.repository.getLearnedWords(), isEmpty);
      expect((await f.repository.getSummary()).status, DailyChallengeStatus.locked);
    });

    test('completion is remembered for today', () async {
      final f = await _Fixture.create();
      expect(f.repository.isCompletedToday, isFalse);
      await f.repository.markCompletedToday();
      expect(f.repository.isCompletedToday, isTrue);
      expect((await f.repository.getSummary()).status, DailyChallengeStatus.completedToday);
    });

    test('completion from a previous day does not count', () async {
      final f = await _Fixture.create();
      await f.prefs.setDailyChallengeDoneOn('2000-01-01');
      expect(f.repository.isCompletedToday, isFalse);
    });
  });

  group('DailyChallengeCubit', () {
    late _Fixture f;
    late DailyChallengeCubit cubit;
    late _FakeTts tts;

    Future<void> setUpCubit(int learnedCount) async {
      f = await _Fixture.create();
      for (final id in await _learnedIds(f, learnedCount)) {
        await f.progress.markWordLearned(id);
      }
      tts = _FakeTts();
      cubit = DailyChallengeCubit(dailyChallengeRepository: f.repository, ttsService: tts);
    }

    Future<DailyChallengeQuestion> settled() async {
      await Future<void>.delayed(Duration.zero);
      return cubit.state as DailyChallengeQuestion;
    }

    tearDown(() => cubit.close());

    test('errors when fewer than the minimum words are learned', () async {
      await setUpCubit(2);
      cubit.init();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<DailyChallengeError>());
    });

    test('caps questions at 6 and only targets learned words', () async {
      await setUpCubit(12);
      final learnedIds = f.progress.getLearnedWordIds();
      cubit.init();
      var q = await settled();
      expect(q.totalQuestions, DailyChallengeRepository.maxQuestions);

      final asked = <String>{};
      for (var i = 0; i < 6; i++) {
        q = cubit.state as DailyChallengeQuestion;
        asked.add(q.targetWord.id);
        expect(learnedIds, contains(q.targetWord.id));
        cubit.selectAnswer(q.targetWord);
        cubit.next();
      }
      expect(asked.length, 6, reason: 'each learned word is asked once');
      expect(cubit.state, isA<DailyChallengeWon>());
    });

    test('with fewer than 6 learned words, asks one question per word', () async {
      await setUpCubit(4);
      cubit.init();
      final q = await settled();
      expect(q.totalQuestions, 4);
    });

    test('options contain the target once, no duplicate texts, and 4 choices', () async {
      await setUpCubit(3);
      cubit.init();
      var q = await settled();
      for (var i = 0; i < 3; i++) {
        q = cubit.state as DailyChallengeQuestion;
        expect(q.options.length, 4);
        expect(q.options.where((w) => w.id == q.targetWord.id).length, 1);
        final texts = q.options.map((w) => w.text.toLowerCase()).toList();
        expect(texts.toSet().length, texts.length);
        cubit.selectAnswer(q.targetWord);
        cubit.next();
      }
    });

    test('speaks the target word when a question appears', () async {
      await setUpCubit(3);
      cubit.init();
      final q = await settled();
      expect(tts.spoken, [q.targetWord.text]);
    });

    test('a wrong answer requeues the question; win only when all are correct', () async {
      await setUpCubit(3);
      cubit.init();
      var q = await settled();
      final firstTarget = q.targetWord;

      // Wrong answer on the first question.
      final wrong = q.options.firstWhere((w) => w.id != firstTarget.id);
      cubit.selectAnswer(wrong);
      q = cubit.state as DailyChallengeQuestion;
      expect(q.isCorrect, isFalse);
      expect(q.correctCount, 0);

      // Locked after answering: a second tap must not change anything.
      cubit.selectAnswer(firstTarget);
      expect((cubit.state as DailyChallengeQuestion).isCorrect, isFalse);
      expect(f.repository.isCompletedToday, isFalse);

      cubit.next();
      final askedAgain = <String>[];
      // Answer everything correctly until the challenge ends; the first word
      // must come back around.
      while (cubit.state is DailyChallengeQuestion) {
        q = cubit.state as DailyChallengeQuestion;
        askedAgain.add(q.targetWord.id);
        expect(q.selectedWordId, isNull);
        cubit.selectAnswer(q.targetWord);
        cubit.next();
      }

      expect(askedAgain.length, 3, reason: '2 remaining + the requeued one');
      expect(askedAgain.last, firstTarget.id, reason: 'the missed question comes back at the end');
      expect(cubit.state, isA<DailyChallengeWon>());
      expect(f.repository.isCompletedToday, isTrue);
    });

    test('is marked complete on the last correct answer, before "Finish" is tapped', () async {
      await setUpCubit(3);
      cubit.init();
      var q = await settled();
      for (var i = 0; i < 2; i++) {
        cubit.selectAnswer(q.targetWord);
        cubit.next();
        q = cubit.state as DailyChallengeQuestion;
      }
      expect(f.repository.isCompletedToday, isFalse);
      cubit.selectAnswer(q.targetWord);
      expect(f.repository.isCompletedToday, isTrue);
      expect(cubit.state, isA<DailyChallengeQuestion>());
    });
  });

  group('HomeCubit launch prompt', () {
    Future<HomeCubit> homeCubit(_Fixture f) async {
      final cubit = HomeCubit(
        vocabRepository: f.vocab,
        preferencesProvider: f.prefs,
        dailyChallengeRepository: f.repository,
        progressRepository: f.progress,
      );
      cubit.init();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return cubit;
    }

    test('fires once per launch when the challenge is available', () async {
      final f = await _Fixture.create();
      for (final id in await _learnedIds(f, 4)) {
        await f.progress.markWordLearned(id);
      }
      final cubit = await homeCubit(f);
      expect((cubit.state as HomeLoaded).dailyChallenge.status, DailyChallengeStatus.available);

      expect(cubit.takeLaunchPrompt(), isTrue);
      expect(cubit.takeLaunchPrompt(), isFalse);
      await cubit.close();
    });

    test('does not fire when already completed today or still locked', () async {
      var f = await _Fixture.create();
      var cubit = await homeCubit(f);
      expect(cubit.takeLaunchPrompt(), isFalse, reason: 'locked');
      await cubit.close();

      f = await _Fixture.create();
      for (final id in await _learnedIds(f, 4)) {
        await f.progress.markWordLearned(id);
      }
      await f.repository.markCompletedToday();
      cubit = await homeCubit(f);
      expect(cubit.takeLaunchPrompt(), isFalse, reason: 'already done today');
      await cubit.close();
    });

    test('refreshDailyChallenge picks up a completed challenge without a loading flash', () async {
      final f = await _Fixture.create();
      for (final id in await _learnedIds(f, 4)) {
        await f.progress.markWordLearned(id);
      }
      final cubit = await homeCubit(f);
      final states = <HomeState>[];
      final sub = cubit.stream.listen(states.add);

      await f.repository.markCompletedToday();
      await cubit.refreshDailyChallenge();
      await Future<void>.delayed(Duration.zero);

      expect(states.whereType<HomeLoading>(), isEmpty);
      expect((cubit.state as HomeLoaded).dailyChallenge.status, DailyChallengeStatus.completedToday);
      await sub.cancel();
      await cubit.close();
    });
  });

  group('unlock progress', () {
    test('summary counts learned words, capped at the unlock target', () async {
      final f = await _Fixture.create();
      var summary = await f.repository.getSummary();
      expect((summary.learnedWords, summary.unlockProgress, summary.wordsRemaining), (0, 0, 3));

      final ids = await _learnedIds(f, 5);
      await f.progress.markWordLearned(ids[0]);
      summary = await f.repository.getSummary();
      expect((summary.learnedWords, summary.unlockProgress, summary.wordsRemaining), (1, 1, 2));

      for (final id in ids) {
        await f.progress.markWordLearned(id);
      }
      summary = await f.repository.getSummary();
      expect((summary.learnedWords, summary.unlockProgress, summary.wordsRemaining), (5, 3, 0));
      expect(summary.status, DailyChallengeStatus.available);
    });

    test('learning the same word twice does not count twice', () async {
      final f = await _Fixture.create();
      final id = (await _learnedIds(f, 1)).single;
      await f.progress.markWordLearned(id);
      await f.progress.markWordLearned(id);
      expect((await f.repository.getSummary()).learnedWords, 1);
    });

    test('progress stream fires only for newly learned words', () async {
      final f = await _Fixture.create();
      var events = 0;
      final sub = f.progress.learnedWordsChanged.listen((_) => events++);
      final id = (await _learnedIds(f, 1)).single;
      await f.progress.markWordLearned(id);
      await f.progress.markWordLearned(id);
      await Future<void>.delayed(Duration.zero);
      expect(events, 1);
      await sub.cancel();
    });

    test('HomeCubit updates 0 → 1 → 2 → 3 / 3 immediately as words are learned, without a loading flash', () async {
      final f = await _Fixture.create();
      final cubit = HomeCubit(
        vocabRepository: f.vocab,
        preferencesProvider: f.prefs,
        dailyChallengeRepository: f.repository,
        progressRepository: f.progress,
      )..init();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final states = <HomeState>[];
      final sub = cubit.stream.listen(states.add);

      DailyChallengeSummary summary() => (cubit.state as HomeLoaded).dailyChallenge;
      expect((summary().unlockProgress, summary().status), (0, DailyChallengeStatus.locked));

      final ids = await _learnedIds(f, 3);
      for (var i = 0; i < 3; i++) {
        await f.progress.markWordLearned(ids[i]);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(summary().unlockProgress, i + 1);
      }
      expect(summary().status, DailyChallengeStatus.available);
      expect(states.whereType<HomeLoading>(), isEmpty);

      await sub.cancel();
      await cubit.close();
    });

    test('CategoryDetailCubit marks learned words and tracks the unlock count live', () async {
      final f = await _Fixture.create();
      final cubit = CategoryDetailCubit(
        vocabRepository: f.vocab,
        progressRepository: f.progress,
        dailyChallengeRepository: f.repository,
      )..init('alphabet');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var loaded = cubit.state as CategoryDetailLoaded;
      expect(loaded.learnedWordIds, isEmpty);
      expect(loaded.dailyChallenge.unlockProgress, 0);

      final word = loaded.words.first;
      await f.progress.markWordLearned(word.id);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      loaded = cubit.state as CategoryDetailLoaded;
      expect(loaded.learnedWordIds, {word.id});
      expect(loaded.dailyChallenge.unlockProgress, 1);
      await cubit.close();
    });

    group('FlashcardCubit toast data', () {
      late _Fixture f;
      late FlashcardCubit cubit;
      late List<String> alphabetIds;

      setUp(() async {
        f = await _Fixture.create();
        cubit = FlashcardCubit(
          vocabRepository: f.vocab,
          progressRepository: f.progress,
          dailyChallengeRepository: f.repository,
          ttsService: _FakeTts(),
        );
        alphabetIds = (await f.vocab.getWords('alphabet')).map((w) => w.id).toList();
      });

      tearDown(() => cubit.close());

      Future<DailyChallengeSummary?> open(String wordId) async {
        cubit.init('alphabet', wordId);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return (cubit.state as FlashcardLoaded).dailyChallengeUpdate;
      }

      test('reports 1/3, 2/3, then the unlock, then goes quiet', () async {
        var update = await open(alphabetIds[0]);
        expect((update!.unlockProgress, update.wordsRemaining, update.status), (1, 2, DailyChallengeStatus.locked));

        update = await open(alphabetIds[1]);
        expect((update!.unlockProgress, update.wordsRemaining, update.status), (2, 1, DailyChallengeStatus.locked));

        update = await open(alphabetIds[2]);
        expect(update!.status, DailyChallengeStatus.available);
        expect(update.unlockProgress, 3);

        expect(await open(alphabetIds[3]), isNull, reason: 'already unlocked — nothing new to say');
      });

      test('re-opening an already learned word says nothing', () async {
        expect(await open(alphabetIds[0]), isNotNull);
        expect(await open(alphabetIds[0]), isNull);
      });

      test('says nothing once today\'s challenge is done', () async {
        for (final id in alphabetIds.take(3)) {
          await f.progress.markWordLearned(id);
        }
        await f.repository.markCompletedToday();
        expect(await open(alphabetIds[3]), isNull);
      });

      test('toggling favourite does not replay the toast', () async {
        expect(await open(alphabetIds[0]), isNotNull);
        cubit.toggleFavorite();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect((cubit.state as FlashcardLoaded).dailyChallengeUpdate, isNull);
      });
    });
  });

  testWidgets('sheet: answer everything correctly to reach the win screen', (tester) async {
    _usePhoneSurface(tester);
    // Asset loading and SharedPreferences are real async work, which would
    // deadlock inside testWidgets' fake-async zone.
    late final _Fixture f;
    await tester.runAsync(() async {
      f = await _Fixture.create();
      for (final id in await _learnedIds(f, 3)) {
        await f.progress.markWordLearned(id);
      }
    });
    final cubit = DailyChallengeCubit(dailyChallengeRepository: f.repository, ttsService: _FakeTts());
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(value: cubit, child: const DailyChallengeSheet()),
      ),
    ));
    await tester.runAsync(() async {
      cubit.init();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('0/3 correct'), findsOneWidget);

    // Miss the first question on purpose, then answer everything right.
    var q = cubit.state as DailyChallengeQuestion;
    final wrong = q.options.firstWhere((w) => w.id != q.targetWord.id);
    await tester.tap(find.text(wrong.text));
    await tester.pumpAndSettle();
    expect(find.textContaining("try that one again"), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    var guard = 0;
    while (cubit.state is DailyChallengeQuestion && guard++ < 10) {
      q = cubit.state as DailyChallengeQuestion;
      await tester.tap(find.text(q.targetWord.text));
      await tester.pumpAndSettle();
      final isLast = f.repository.isCompletedToday;
      expect(find.text(isLast ? 'Finish' : 'Next'), findsOneWidget);
      await tester.tap(find.text(isLast ? 'Finish' : 'Next'));
      await tester.pumpAndSettle();
    }

    expect(cubit.state, isA<DailyChallengeWon>());
    expect(find.text('Challenge complete!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(f.repository.isCompletedToday, isTrue);
  });

  testWidgets('sheet: every option and the Next button fit on a small phone without scrolling', (tester) async {
    _usePhoneSurface(tester, width: 375, height: 667); // iPhone SE
    late final _Fixture f;
    await tester.runAsync(() async {
      f = await _Fixture.create();
      for (final id in await _learnedIds(f, 3)) {
        await f.progress.markWordLearned(id);
      }
    });
    final cubit = DailyChallengeCubit(dailyChallengeRepository: f.repository, ttsService: _FakeTts());
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BlocProvider.value(value: cubit, child: const DailyChallengeSheet())),
    ));
    await tester.runAsync(() async {
      cubit.init();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final q = cubit.state as DailyChallengeQuestion;
    await tester.tap(find.text(q.targetWord.text));
    await tester.pumpAndSettle();

    final nextTop = tester.getTopLeft(find.text('Next')).dy;
    for (final option in q.options) {
      final finder = find.text(option.text);
      expect(finder, findsOneWidget);
      expect(tester.getBottomLeft(finder).dy, lessThanOrEqualTo(nextTop), reason: '${option.text} overlaps Next');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('home banner: says what to learn, where, and counts up to Unlocked', (tester) async {
    _usePhoneSurface(tester);
    late final _Fixture f;
    late final HomeCubit cubit;
    await tester.runAsync(() async {
      f = await _Fixture.create();
      cubit = HomeCubit(
        vocabRepository: f.vocab,
        preferencesProvider: f.prefs,
        dailyChallengeRepository: f.repository,
        progressRepository: f.progress,
      )..init();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    addTearDown(cubit.close);

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => BlocProvider.value(value: cubit, child: const HomePage())),
      GoRoute(path: '/category/:id', builder: (_, s) => Scaffold(body: Text('category ${s.pathParameters['id']}'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // What / where / how many.
    expect(find.text('Unlock the Daily Challenge'), findsOneWidget);
    expect(find.text('Open any 3 word cards in Alphabet, Animals or Food'), findsOneWidget);
    expect(find.text('0 / 3 words learned'), findsOneWidget);

    final ids = await tester.runAsync(() => _learnedIds(f, 3)) as List<String>;
    for (var i = 1; i <= 2; i++) {
      await tester.runAsync(() async {
        await f.progress.markWordLearned(ids[i - 1]);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('$i / 3 words learned'), findsOneWidget, reason: 'updates immediately after learning');
      expect(find.text('Unlock the Daily Challenge'), findsOneWidget);
    }

    // Tapping the locked banner takes the child to Alphabet.
    await tester.tap(find.text('Unlock the Daily Challenge'));
    await tester.pumpAndSettle();
    expect(find.text('category alphabet'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await f.progress.markWordLearned(ids[2]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('3 / 3 words learned — Daily Challenge Unlocked!'), findsOneWidget);
    expect(find.text('Unlock the Daily Challenge'), findsNothing);
  });

  testWidgets('category page: learned words get a check and the hint counts up', (tester) async {
    _usePhoneSurface(tester);
    late final _Fixture f;
    late final CategoryDetailCubit cubit;
    await tester.runAsync(() async {
      f = await _Fixture.create();
      cubit = CategoryDetailCubit(
        vocabRepository: f.vocab,
        progressRepository: f.progress,
        dailyChallengeRepository: f.repository,
      )..init('alphabet');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    addTearDown(cubit.close);

    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => BlocProvider.value(value: cubit, child: const CategoryDetailPage(categoryId: 'alphabet')),
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.textContaining('0 / 3 words learned to unlock the Daily Challenge'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    final firstWord = (cubit.state as CategoryDetailLoaded).words.first;
    await tester.runAsync(() async {
      await f.progress.markWordLearned(firstWord.id);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.textContaining('1 / 3 words learned to unlock the Daily Challenge'), findsOneWidget);

    final ids = await tester.runAsync(() => _learnedIds(f, 3)) as List<String>;
    await tester.runAsync(() async {
      for (final id in ids) {
        await f.progress.markWordLearned(id);
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('to unlock the Daily Challenge'), findsNothing, reason: 'hint disappears once unlocked');
  });

  testWidgets('sheet opened from inside a nested navigator (bottom-nav shell) covers the nav bar', (tester) async {
    _usePhoneSurface(tester);
    late final _Fixture f;
    await tester.runAsync(() async => f = await _Fixture.create());
    locator.registerFactory(() => DailyChallengeCubit(dailyChallengeRepository: f.repository, ttsService: _FakeTts()));
    addTearDown(locator.reset);

    // Mirrors the app: a shell Scaffold owns the NavigationBar and hosts the
    // tab content in its own nested Navigator.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Center(
              child: ElevatedButton(onPressed: () => showDailyChallengeSheet(context), child: const Text('open')),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Library'),
          ],
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final screenHeight = tester.view.physicalSize.height;
    expect(tester.getBottomLeft(find.byType(DailyChallengeSheet)).dy, screenHeight,
        reason: 'sheet must extend to the bottom of the screen, over the nav bar');
    expect(find.byType(NavigationBar).hitTestable(), findsNothing, reason: 'nav bar must not be tappable behind the sheet');
  });

  testWidgets('win celebration card is light with readable text (not a muddy tint)', (tester) async {
    _usePhoneSurface(tester);
    late final _Fixture f;
    await tester.runAsync(() async {
      f = await _Fixture.create();
      for (final id in await _learnedIds(f, 3)) {
        await f.progress.markWordLearned(id);
      }
    });
    final cubit = DailyChallengeCubit(dailyChallengeRepository: f.repository, ttsService: _FakeTts());
    addTearDown(cubit.close);

    // The app's real theme: the card tint is derived from its colour scheme.
    await tester.pumpWidget(MaterialApp(
      theme: MaterialTheme().light(),
      home: Scaffold(body: BlocProvider.value(value: cubit, child: const DailyChallengeSheet())),
    ));
    await tester.runAsync(() {
      cubit.init();
      return Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    while (cubit.state is DailyChallengeQuestion) {
      cubit.selectAnswer((cubit.state as DailyChallengeQuestion).targetWord);
      cubit.next();
    }
    // Let the card finish its pop-in, but not fade out (2.2s total).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final card = tester.widget<Container>(
      find.ancestor(of: find.text('You did it!'), matching: find.byType(Container)).first,
    );
    final cardColor = (card.decoration as BoxDecoration).color!;
    const ink = Color(0xFF201C3A); // ConfettiOverlay's text color

    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) / (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
    }

    expect(cardColor.computeLuminance(), greaterThan(0.8), reason: 'card should be a light tint, got $cardColor');
    expect(contrast(cardColor, ink), greaterThan(7), reason: 'text must be easy to read on $cardColor');

    await tester.pump(const Duration(seconds: 3)); // let the overlay remove itself
  });
}

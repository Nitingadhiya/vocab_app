import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/enums/route_names.dart';
import 'package:vocab_app/core/route/import_list.dart';
import 'package:vocab_app/data/sources/local/preferences_provider.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/common/bottom_nav_shell.dart';

GoRouter buildAppRouter() {
  final hasOnboarded = locator<PreferencesProvider>().getHasOnboarded();

  return GoRouter(
    initialLocation: hasOnboarded ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: RouteName.onboarding.name,
        builder: (context, state) => BlocProvider(
          create: (_) => locator.get<OnboardingCubit>(),
          child: const OnboardingPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomNavShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              name: RouteName.home.name,
              builder: (context, state) => BlocProvider.value(
                value: locator.get<HomeCubit>(),
                child: const HomePage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              name: RouteName.library.name,
              builder: (context, state) => BlocProvider.value(
                value: locator.get<LibraryCubit>(),
                child: const LibraryPage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/progress',
              name: RouteName.progress.name,
              builder: (context, state) => BlocProvider.value(
                value: locator.get<ProgressCubit>(),
                child: const ProgressPage(),
              ),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/category/:categoryId',
        name: RouteName.categoryDetail.name,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return BlocProvider(
            create: (_) => locator.get<CategoryDetailCubit>()..init(categoryId),
            child: CategoryDetailPage(categoryId: categoryId),
          );
        },
      ),
      GoRoute(
        path: '/category/:categoryId/word/:wordId',
        name: RouteName.flashcard.name,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final wordId = state.pathParameters['wordId']!;
          return BlocProvider(
            create: (_) => locator.get<FlashcardCubit>()..init(categoryId, wordId),
            child: FlashcardPage(categoryId: categoryId, wordId: wordId),
          );
        },
      ),
      GoRoute(
        path: '/category/:categoryId/quiz',
        name: RouteName.quiz.name,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return BlocProvider(
            create: (_) => locator.get<QuizCubit>()..init(categoryId),
            child: QuizPage(categoryId: categoryId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: RouteName.settings.name,
        builder: (context, state) => BlocProvider(
          create: (_) => locator.get<SettingsCubit>()..init(),
          child: const SettingsPage(),
        ),
      ),
    ],
  );
}

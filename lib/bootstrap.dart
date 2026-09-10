import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/route/app_router.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';
import 'package:vocab_app/presentation/features/library/viewmodel/library_cubit.dart';
import 'package:vocab_app/presentation/features/progress/viewmodel/progress_cubit.dart';

Future<GoRouter> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  // Warm up the persistent bottom-nav tabs so they have data before first paint.
  locator<HomeCubit>().init();
  locator<LibraryCubit>().init();
  locator<ProgressCubit>().init();

  return buildAppRouter();
}

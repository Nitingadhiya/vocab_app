import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/theme.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/app/viewmodel/app_cubit.dart';

class AppView extends StatelessWidget {
  final GoRouter router;

  const AppView({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme();

    return BlocProvider.value(
      value: locator<AppCubit>(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Vocablurry',
            debugShowCheckedModeBanner: false,
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: state.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

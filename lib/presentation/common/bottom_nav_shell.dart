import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/di/service_locator.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';
import 'package:vocab_app/presentation/features/library/viewmodel/library_cubit.dart';
import 'package:vocab_app/presentation/features/progress/viewmodel/progress_cubit.dart';

/// Persistent bottom-nav scaffold wrapping the Home / Library / Progress branches.
class BottomNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    final isReselect = index == navigationShell.currentIndex;
    switch (index) {
      case 0:
        locator<HomeCubit>().init();
        break;
      case 1:
        locator<LibraryCubit>().init();
        break;
      case 2:
        locator<ProgressCubit>().init();
        break;
    }
    navigationShell.goBranch(index, initialLocation: isReselect);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(AppCss.captionSmall.size(12)),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
        ],
      ),
    );
  }
}

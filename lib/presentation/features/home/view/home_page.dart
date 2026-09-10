import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/category_card.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: state is HomeLoading || state is HomeInitial
                ? const LoadingWidget()
                : state is HomeLoaded
                    ? _HomeContent(state: state)
                    : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(Insets.i20, Insets.i16, Insets.i20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: Sizes.s40,
                      height: Sizes.s40,
                      decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text('🧒', style: TextStyle(fontSize: 20)),
                    ),
                    SizedBox(width: Insets.i10),
                    Text('Vocablurry', style: AppCss.bodyBaseSemibold.size(20).textColor(colorScheme.primary)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: Icon(Icons.settings_rounded, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                SizedBox(height: Insets.i12),
                Text('Hello, ${state.childName}!', style: AppCss.h6.textColor(colorScheme.onSurface)),
                SizedBox(height: Insets.i4),
                Text(
                  "Let's explore new words today 🌈",
                  style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                SizedBox(height: Insets.i20),
                _ReadyBanner(
                  onTap: () {
                    if (state.categories.isNotEmpty) {
                      context.push('/category/${state.categories.first.category.id}');
                    }
                  },
                ),
                SizedBox(height: Insets.i24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: Insets.i20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = state.categories[index];
                return CategoryCard(
                  category: item.category,
                  wordCount: item.wordCount,
                  onTap: () => context.push('/category/${item.category.id}'),
                );
              },
              childCount: state.categories.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: Insets.i24)),
      ],
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ReadyBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Container(
        padding: EdgeInsets.all(Insets.i16),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        child: Row(
          children: [
            const Text('🦁', style: TextStyle(fontSize: 32)),
            SizedBox(width: Insets.i12),
            Expanded(
              child: Text(
                'Ready to learn\nsomething new?',
                style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSecondaryContainer),
              ),
            ),
            Container(
              width: Sizes.s40,
              height: Sizes.s40,
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.play_arrow_rounded, color: colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

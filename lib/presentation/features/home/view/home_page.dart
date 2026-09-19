import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/repositories/daily_challenge_repository.dart';
import 'package:vocab_app/presentation/common/category_card.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/features/daily_challenge/view/daily_challenge_sheet.dart';
import 'package:vocab_app/presentation/features/home/viewmodel/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // HomeCubit is warmed up in bootstrap, so it's usually already loaded by
    // the time this page first builds and the listener below never sees the
    // transition — check once explicitly as well.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptDailyChallenge());
  }

  void _maybePromptDailyChallenge() {
    if (!mounted) return;
    if (context.read<HomeCubit>().takeLaunchPrompt()) _openDailyChallenge();
  }

  Future<void> _openDailyChallenge() async {
    final homeCubit = context.read<HomeCubit>();
    await showDailyChallengeSheet(context);
    homeCubit.refreshDailyChallenge();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          showAlertDialog(context: context, body: state.message);
        }
        if (state is HomeLoaded) _maybePromptDailyChallenge();
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: state is HomeLoading || state is HomeInitial
                ? const LoadingWidget()
                : state is HomeLoaded
                    ? _HomeContent(state: state, onOpenDailyChallenge: _openDailyChallenge)
                    : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  final VoidCallback onOpenDailyChallenge;

  const _HomeContent({required this.state, required this.onOpenDailyChallenge});

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
                    Text('Word Stars', style: AppCss.bodyBaseSemibold.size(20).textColor(colorScheme.primary)),
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
                _DailyChallengeBanner(
                  summary: state.dailyChallenge,
                  learnableCategories: state.categories
                      .map((c) => c.category)
                      .where((c) => c.id != DailyChallengeRepository.excludedCategoryId)
                      .toList(),
                  onPlay: onOpenDailyChallenge,
                ),
                SizedBox(height: Insets.i12),
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
                  index: index,
                  onTap: () => context.push(
                    item.category.id == 'phonics' ? '/phonics' : '/category/${item.category.id}',
                  ),
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

class _DailyChallengeBanner extends StatelessWidget {
  final DailyChallengeSummary summary;

  /// Categories whose words count towards the unlock, in display order.
  final List<Category> learnableCategories;
  final VoidCallback onPlay;

  const _DailyChallengeBanner({required this.summary, required this.learnableCategories, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = summary.status;
    final isLocked = status == DailyChallengeStatus.locked;
    final isAvailable = status == DailyChallengeStatus.available;
    // While locked, tapping takes the child to where they can learn words.
    final learnCategory = learnableCategories.isEmpty ? null : learnableCategories.first;
    final onTap = isAvailable
        ? onPlay
        : isLocked && learnCategory != null
            ? () => context.push('/category/${learnCategory.id}')
            : null;

    final (emoji, title, subtitle, trailingIcon) = switch (status) {
      DailyChallengeStatus.available => (
          '🏆',
          'Daily Challenge',
          '${summary.unlockProgress} / ${DailyChallengeRepository.minLearnedWords} words learned — '
              'Daily Challenge Unlocked!',
          Icons.play_arrow_rounded,
        ),
      DailyChallengeStatus.completedToday => (
          '🎉',
          'Challenge complete!',
          'Come back tomorrow for a new one',
          Icons.check_rounded,
        ),
      DailyChallengeStatus.locked => (
          '🔒',
          'Unlock the Daily Challenge',
          'Open any ${DailyChallengeRepository.minLearnedWords} word cards in ${_categoryNames(learnableCategories)}',
          Icons.arrow_forward_rounded,
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Container(
        padding: EdgeInsets.all(Insets.i16),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                SizedBox(width: Insets.i12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onTertiaryContainer)),
                      SizedBox(height: Insets.i2),
                      Text(
                        subtitle,
                        style: AppCss.captionSmall.size(13).textColor(colorScheme.onTertiaryContainer.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Insets.i8),
                Container(
                  width: Sizes.s40,
                  height: Sizes.s40,
                  decoration: BoxDecoration(
                    color: onTap != null ? colorScheme.tertiary : colorScheme.onTertiaryContainer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(trailingIcon, color: onTap != null ? colorScheme.onTertiary : colorScheme.onTertiaryContainer),
                ),
              ],
            ),
            if (isLocked) ...[
              SizedBox(height: Insets.i12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                child: LinearProgressIndicator(
                  value: summary.unlockProgress / DailyChallengeRepository.minLearnedWords,
                  minHeight: Sizes.s8,
                  backgroundColor: colorScheme.onTertiaryContainer.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(colorScheme.tertiary),
                ),
              ),
              SizedBox(height: Insets.i6),
              Text(
                '${summary.unlockProgress} / ${DailyChallengeRepository.minLearnedWords} words learned',
                style: AppCss.captionSmall.size(13).textColor(colorScheme.onTertiaryContainer),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// "Alphabet", "Alphabet or Animals", "Alphabet, Animals or Food" — the
  /// first few categories, so the child sees concrete places to go.
  static String _categoryNames(List<Category> categories) {
    final names = categories.take(3).map((c) => c.name).toList();
    if (names.isEmpty) return 'any category';
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} or ${names.last}';
  }
}

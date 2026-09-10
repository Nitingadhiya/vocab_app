import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/features/flashcard/viewmodel/flashcard_cubit.dart';

class FlashcardPage extends StatelessWidget {
  final String categoryId;
  final String wordId;

  const FlashcardPage({super.key, required this.categoryId, required this.wordId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flashcardCubit = context.read<FlashcardCubit>();

    return BlocConsumer<FlashcardCubit, FlashcardState>(
      listener: (context, state) {
        if (state is FlashcardError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (state is FlashcardLoaded)
                IconButton(
                  onPressed: flashcardCubit.toggleFavorite,
                  icon: Icon(
                    state.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: colorScheme.secondary,
                  ),
                ),
            ],
          ),
          body: state is FlashcardLoading || state is FlashcardInitial
              ? const LoadingWidget()
              : state is FlashcardLoaded
                  ? _FlashcardContent(categoryId: categoryId, state: state)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _FlashcardContent extends StatelessWidget {
  final String categoryId;
  final FlashcardLoaded state;

  const _FlashcardContent({required this.categoryId, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final word = state.currentWord;
    final flashcardCubit = context.read<FlashcardCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.i24),
      child: Column(
        children: [
          const Spacer(),
          if (word.letter != null) ...[
            Text(word.letter!, style: AppCss.h1.bold.textColor(colorScheme.primary)),
            SizedBox(height: Insets.i12),
          ],
          Container(
            width: Sizes.s160,
            height: Sizes.s160,
            decoration: BoxDecoration(
              color: state.category.colorHex.toColor(),
              borderRadius: BorderRadius.circular(AppRadius.r24),
            ),
            alignment: Alignment.center,
            child: Text(word.emoji, style: const TextStyle(fontSize: 80)),
          ),
          SizedBox(height: Insets.i20),
          Text(word.text, style: AppCss.h5.bold.textColor(colorScheme.onSurface)),
          SizedBox(height: Insets.i24),
          GestureDetector(
            onTap: flashcardCubit.speakCurrent,
            child: Container(
              width: Sizes.s64,
              height: Sizes.s64,
              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.volume_up_rounded, color: colorScheme.onPrimary, size: Sizes.s28),
            ),
          ),
          SizedBox(height: Insets.i12),
          Text(
            'Tap to hear the word',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const Spacer(flex: 2),
          _PagerRow(categoryId: categoryId, state: state),
          SizedBox(height: Insets.i24),
        ],
      ),
    );
  }
}

class _PagerRow extends StatelessWidget {
  final String categoryId;
  final FlashcardLoaded state;

  const _PagerRow({required this.categoryId, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPrev = state.currentIndex > 0;
    final canNext = state.currentIndex < state.words.length - 1;

    void goTo(int index) {
      context.pushReplacement('/category/$categoryId/word/${state.words[index].id}');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavCircle(
          icon: Icons.chevron_left_rounded,
          enabled: canPrev,
          onTap: () => goTo(state.currentIndex - 1),
        ),
        SizedBox(width: Insets.i16),
        if (state.words.length <= 10)
          Row(
            children: List.generate(state.words.length, (index) {
              final active = index == state.currentIndex;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.i3),
                child: Container(
                  width: active ? Sizes.s12 : Sizes.s8,
                  height: Sizes.s8,
                  decoration: BoxDecoration(
                    color: active ? colorScheme.primary : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.r6),
                  ),
                ),
              );
            }),
          )
        else
          Text(
            '${state.currentIndex + 1} / ${state.words.length}',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        SizedBox(width: Insets.i16),
        _NavCircle(
          icon: Icons.chevron_right_rounded,
          enabled: canNext,
          onTap: () => goTo(state.currentIndex + 1),
        ),
      ],
    );
  }
}

class _NavCircle extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavCircle({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.r24),
      child: Container(
        width: Sizes.s44,
        height: Sizes.s44,
        decoration: BoxDecoration(
          color: enabled ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: enabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

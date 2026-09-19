import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/pager_row.dart';
import 'package:vocab_app/presentation/features/phonics/viewmodel/phonics_cubit.dart';

/// Letter-sound practice screen: shows one big uppercase letter at a time and
/// plays its phonics sound automatically (see [PhonicsCubit.speakCurrent]).
/// No vocab word or emoji is shown here — that pairing belongs to the
/// Alphabet category's flashcard screen, not this one.
class PhonicsPage extends StatelessWidget {
  final String letterId;

  const PhonicsPage({super.key, required this.letterId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<PhonicsCubit, PhonicsState>(
      listener: (context, state) {
        if (state is PhonicsError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Phonics', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface)),
          ),
          body: state is PhonicsLoading || state is PhonicsInitial
              ? const LoadingWidget()
              : state is PhonicsLoaded
                  ? _PhonicsContent(state: state)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _PhonicsContent extends StatelessWidget {
  final PhonicsLoaded state;

  const _PhonicsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final letter = state.currentLetter;
    final phonicsCubit = context.read<PhonicsCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.i24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: Sizes.s160,
            height: Sizes.s160,
            decoration: BoxDecoration(
              color: state.category.colorHex.toColor(),
              borderRadius: BorderRadius.circular(AppRadius.r24),
            ),
            alignment: Alignment.center,
            child: Text(
              letter.letter ?? letter.text,
              style: AppCss.h1.bold.size(72).textColor(colorScheme.primary),
            ),
          ),
          SizedBox(height: Insets.i30),
          GestureDetector(
            onTap: phonicsCubit.speakCurrent,
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
            'Tap to hear the sound',
            style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const Spacer(flex: 2),
          PagerRow(
            currentIndex: state.currentIndex,
            itemCount: state.letters.length,
            onGoTo: (index) => context.pushReplacement('/phonics/${state.letters[index].id}'),
          ),
          SizedBox(height: Insets.i24),
        ],
      ),
    );
  }
}

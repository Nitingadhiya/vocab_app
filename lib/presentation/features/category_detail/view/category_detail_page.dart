import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/emoji_tile.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/primary_button.dart';
import 'package:vocab_app/presentation/features/category_detail/viewmodel/category_detail_cubit.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryId;

  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CategoryDetailCubit, CategoryDetailState>(
      listener: (context, state) {
        if (state is CategoryDetailError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is CategoryDetailLoaded ? state.category.name : '',
              style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface),
            ),
          ),
          body: state is CategoryDetailLoading || state is CategoryDetailInitial
              ? const LoadingWidget()
              : state is CategoryDetailLoaded
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.all(Insets.i20),
                            itemCount: state.words.length,
                            separatorBuilder: (_, _) => SizedBox(height: Insets.i12),
                            itemBuilder: (context, index) {
                              final word = state.words[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(AppRadius.r16),
                                onTap: () => context.push('/category/$categoryId/word/${word.id}'),
                                child: Container(
                                  padding: EdgeInsets.all(Insets.i12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(AppRadius.r16),
                                  ),
                                  child: Row(
                                    children: [
                                      EmojiTile(
                                        emoji: word.emoji,
                                        backgroundColor: state.category.colorHex.toColor(),
                                        size: Sizes.s48,
                                        shape: BoxShape.rectangle,
                                      ),
                                      SizedBox(width: Insets.i16),
                                      Expanded(
                                        child: Text(
                                          word.text,
                                          style: AppCss.bodySmallSemiBold.size(18).textColor(colorScheme.onSurface),
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(Insets.i20, 0, Insets.i20, Insets.i20),
                          child: PrimaryButton(
                            label: 'Quiz Me',
                            trailingIcon: Icons.headphones_rounded,
                            backgroundColor: colorScheme.tertiary,
                            foregroundColor: colorScheme.onTertiary,
                            onPressed: state.words.isEmpty ? null : () => context.push('/category/$categoryId/quiz'),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

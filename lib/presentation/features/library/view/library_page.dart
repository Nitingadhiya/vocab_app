import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/category_card.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/features/library/viewmodel/library_cubit.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<LibraryCubit, LibraryState>(
      listener: (context, state) {
        if (state is LibraryError) {
          showAlertDialog(context: context, body: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Library', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
          body: state is LibraryLoading || state is LibraryInitial
              ? const LoadingWidget()
              : state is LibraryLoaded
                  ? GridView.builder(
                      padding: EdgeInsets.all(Insets.i20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final item = state.categories[index];
                        return CategoryCard(
                          category: item.category,
                          wordCount: item.wordCount,
                          onTap: () => context.push('/category/${item.category.id}'),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

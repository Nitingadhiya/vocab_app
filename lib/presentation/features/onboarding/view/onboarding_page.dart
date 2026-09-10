import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/primary_button.dart';
import 'package:vocab_app/presentation/features/onboarding/viewmodel/onboarding_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onboardingCubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.i24),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Sizes.s64,
                        height: Sizes.s64,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('🦉', style: TextStyle(fontSize: 34)),
                      ),
                    ],
                  ),
                  SizedBox(height: Insets.i16),
                  Text(
                    'Vocablurry',
                    style: AppCss.h3.bold.textColor(colorScheme.primary),
                  ),
                  SizedBox(height: Insets.i8),
                  Text(
                    'Small Steps. Big Words.',
                    style: AppCss.bodyBaseSemibold.size(18).textColor(colorScheme.onSurface),
                  ),
                  SizedBox(height: Insets.i12),
                  Text(
                    'Fun vocabulary learning\nfor curious little minds.',
                    textAlign: TextAlign.center,
                    style: AppCss.caption.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  SizedBox(height: Insets.i40),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Insets.i30),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.r24),
                    ),
                    child: const Text(
                      '🧒📖🐶',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 56),
                    ),
                  ),
                  const Spacer(flex: 2),
                  PrimaryButton(
                    label: 'Get Started',
                    onPressed: onboardingCubit.getStarted,
                  ),
                  SizedBox(height: Insets.i24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

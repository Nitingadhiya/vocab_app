import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/app/viewmodel/app_cubit.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/features/settings/viewmodel/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Settings', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface))),
          body: state is SettingsLoaded ? _SettingsContent(childName: state.childName) : const LoadingWidget(),
        );
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final String childName;

  const _SettingsContent({required this.childName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appCubit = context.read<AppCubit>();

    return ListView(
      padding: EdgeInsets.all(Insets.i20),
      children: [
        Container(
          padding: EdgeInsets.all(Insets.i16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Row(
            children: [
              Container(
                width: Sizes.s48,
                height: Sizes.s48,
                decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('🧒', style: TextStyle(fontSize: 24)),
              ),
              SizedBox(width: Insets.i12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(childName, style: AppCss.bodySmallSemiBold.size(16).textColor(colorScheme.onSurface)),
                    Text('Age 3+', style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
        SizedBox(height: Insets.i20),
        BlocBuilder<AppCubit, AppState>(
          builder: (context, appState) {
            return Column(
              children: [
                _SettingsTile(
                  icon: Icons.volume_up_rounded,
                  title: 'Audio Settings',
                  trailing: Switch(
                    value: appState.audioEnabled,
                    activeThumbColor: colorScheme.primary,
                    onChanged: appCubit.setAudioEnabled,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.nightlight_round,
                  title: 'Appearance',
                  trailing: TextButton(
                    onPressed: () {
                      final next = appState.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                      appCubit.setThemeMode(next);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appState.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                          style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        _SettingsTile(
          icon: Icons.shield_rounded,
          title: 'Parental Controls',
          onTap: () => showAlertDialog(
            context: context,
            title: 'Parental Controls',
            body: 'Manage screen time and content settings here soon.',
          ),
        ),
        _SettingsTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          onTap: () => showAlertDialog(
            context: context,
            title: 'Help & Support',
            body: 'Need help? Reach out to us any time.',
          ),
        ),
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          title: 'About Vocablurry',
          onTap: () => showAlertDialog(
            context: context,
            title: 'About Vocablurry',
            body: 'Vocablurry helps curious little minds learn new words, one small step at a time.',
          ),
        ),
        SizedBox(height: Insets.i16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Insets.i20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Column(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 28)),
              SizedBox(height: Insets.i8),
              Text(
                'Together we make learning fun! ❤',
                textAlign: TextAlign.center,
                style: AppCss.captionSmall.textColor(colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Insets.i12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: Sizes.s24),
            SizedBox(width: Insets.i16),
            Expanded(child: Text(title, style: AppCss.bodySmall.size(16).textColor(colorScheme.onSurface))),
            trailing ?? Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

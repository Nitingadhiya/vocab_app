import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

/// App-wide theme configuration. Only used from the root app widget.
class MaterialTheme {
  static const Color _seed = Color(0xFF6C63FF); // Word Stars purple
  static const Color _accentAmber = Color(0xFFFFC93C); // stars / streak
  static const Color _accentGreen = Color(0xFF22C55E); // success / correct
  static const Color _accentPink = Color(0xFFFF6B81); // errors / wrong answer

  ColorScheme lightScheme({double contrastLevel = 0}) {
    return ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      contrastLevel: contrastLevel,
    ).copyWith(
      secondary: _accentAmber,
      onSecondary: const Color(0xFF3A2900),
      secondaryContainer: const Color(0xFFFFF3D6),
      onSecondaryContainer: const Color(0xFF4A3600),
      tertiary: _accentGreen,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD9F7E3),
      onTertiaryContainer: const Color(0xFF0B3D22),
      error: _accentPink,
      surface: const Color(0xFFF7F6FD),
      onSurface: const Color(0xFF201C3A),
    );
  }

  ColorScheme darkScheme({double contrastLevel = 0}) {
    return ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      contrastLevel: contrastLevel,
    ).copyWith(
      secondary: _accentAmber,
      onSecondary: const Color(0xFF3A2900),
      tertiary: _accentGreen,
      onTertiary: Colors.white,
      error: _accentPink,
    );
  }

  ThemeData _themeFrom(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // fontFamily intentionally left unset — see the note in app_css.dart.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppCss.bodyBaseSemibold.textColor(scheme.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: Size(double.infinity, ButtonHeight.h50),
          textStyle: AppCss.bodyBaseSemibold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
      ),
    );
  }

  ThemeData light() => _themeFrom(lightScheme());
  ThemeData lightMediumContrast() => _themeFrom(lightScheme(contrastLevel: 0.5));
  ThemeData lightHighContrast() => _themeFrom(lightScheme(contrastLevel: 1));

  ThemeData dark() => _themeFrom(darkScheme());
  ThemeData darkMediumContrast() => _themeFrom(darkScheme(contrastLevel: 0.5));
  ThemeData darkHighContrast() => _themeFrom(darkScheme(contrastLevel: 1));
}

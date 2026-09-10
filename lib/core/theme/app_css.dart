import 'package:flutter/material.dart';

// Note: fontFamily is intentionally left unset (platform default) below.
// `Fonts.inter` in scale.dart is a placeholder name with no bundled font
// asset behind it yet — setting an unresolved fontFamily here disables the
// engine's fallback-font cascade for glyphs the "family" doesn't cover
// (color emoji in particular render as tofu boxes). Once a real font is
// added under `fonts:` in pubspec.yaml, wire `fontFamily: Fonts.inter` back
// into these styles.

/// Centralized typography. Always use these styles instead of
/// `Theme.of(context).textTheme` or ad-hoc `TextStyle`s.
class AppCss {
  AppCss._();

  // Headings
  static const TextStyle h1 = TextStyle(fontSize: 72, fontWeight: FontWeight.w500);
  static const TextStyle h2 = TextStyle(fontSize: 56, fontWeight: FontWeight.w500);
  static const TextStyle h3 = TextStyle(fontSize: 44, fontWeight: FontWeight.w500);
  static const TextStyle h4 = TextStyle(fontSize: 40, fontWeight: FontWeight.w500);
  static const TextStyle h5 = TextStyle(fontSize: 32, fontWeight: FontWeight.w500);
  static const TextStyle h6 = TextStyle(fontSize: 28, fontWeight: FontWeight.w500);

  // Body
  static const TextStyle bodyXXL = TextStyle(fontSize: 50, fontWeight: FontWeight.w400);
  static const TextStyle bodyExtraLarge = TextStyle(fontSize: 40, fontWeight: FontWeight.w400);
  static const TextStyle bodyLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w400);
  static const TextStyle bodyLargeSemibold = TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
  static const TextStyle bodyBase = TextStyle(fontSize: 28, fontWeight: FontWeight.w400);
  static const TextStyle bodyBaseSemibold = TextStyle(fontSize: 28, fontWeight: FontWeight.w600);
  static const TextStyle bodySmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
  static const TextStyle bodySmallSemiBold = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);

  // Captions
  static const TextStyle caption = TextStyle(fontSize: 20, fontWeight: FontWeight.w400);
  static const TextStyle captionSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
}

import 'package:flutter/material.dart';

/// Fluent modifiers for [TextStyle] so features never build raw [TextStyle]s.
extension TextStyleExtensions on TextStyle {
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);
  TextStyle get extraLight => copyWith(fontWeight: FontWeight.w200);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
  TextStyle get black => copyWith(fontWeight: FontWeight.w900);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
  TextStyle get overLine => copyWith(decoration: TextDecoration.overline);

  TextStyle textColor(Color color) => copyWith(color: color);
  TextStyle textBackgroundColor(Color color) => copyWith(backgroundColor: color);

  TextStyle size(double size) => copyWith(fontSize: size);
  TextStyle scale(double factor) => copyWith(fontSize: (fontSize ?? 14) * factor);

  TextStyle letterSpace(double space) => copyWith(letterSpacing: space);
  TextStyle wordSpace(double space) => copyWith(wordSpacing: space);
  TextStyle textHeight(double height) => copyWith(height: height);
}

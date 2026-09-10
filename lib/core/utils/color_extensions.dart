import 'package:flutter/material.dart';

extension HexColor on String {
  /// Parses a "#RRGGBB" or "#AARRGGBB" hex string into a [Color].
  Color toColor() {
    var hex = replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

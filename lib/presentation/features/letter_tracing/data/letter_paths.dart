import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Normalized (0-100, y-down) stroke geometry used as a tracing guide.
/// Each letter is a list of strokes (pen-lift segments); each stroke is an
/// ordered list of anchor points connected by straight lines. Curved
/// letters (O, C, S, ...) simply use enough anchor points around the curve
/// to read as round once [densifyStrokes] fills in the segments.
class LetterPathData {
  final List<List<Offset>> strokes;
  const LetterPathData(this.strokes);
}

/// Uppercase-only for now. Lowercase forms can be authored later with the
/// exact same schema (see `lowercaseLetterPaths` below) — the tracing
/// engine, canvas, and cubit already accept an `uppercase` flag via
/// [letterPathFor] and don't need to change when lowercase is added.
final Map<String, LetterPathData> uppercaseLetterPaths = {
  'A': const LetterPathData([
    [Offset(10, 90), Offset(50, 10)],
    [Offset(50, 10), Offset(90, 90)],
    [Offset(25, 60), Offset(75, 60)],
  ]),
  'B': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 12), Offset(60, 12), Offset(72, 28), Offset(60, 45), Offset(20, 45)],
    [Offset(20, 47), Offset(65, 47), Offset(78, 68), Offset(65, 88), Offset(20, 88)],
  ]),
  'C': LetterPathData([_arc(cx: 50, cy: 50, rx: 34, ry: 40, startDeg: 40, endDeg: 320)]),
  'D': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 10), Offset(55, 10), Offset(75, 25), Offset(82, 50), Offset(75, 75), Offset(55, 90), Offset(20, 90)],
  ]),
  'E': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 10), Offset(80, 10)],
    [Offset(20, 50), Offset(65, 50)],
    [Offset(20, 90), Offset(80, 90)],
  ]),
  'F': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 10), Offset(80, 10)],
    [Offset(20, 50), Offset(65, 50)],
  ]),
  'G': LetterPathData([
    _arc(cx: 50, cy: 50, rx: 34, ry: 40, startDeg: 40, endDeg: 330),
    const [Offset(80, 58), Offset(55, 58)],
  ]),
  'H': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(80, 10), Offset(80, 90)],
    [Offset(20, 50), Offset(80, 50)],
  ]),
  'I': const LetterPathData([
    [Offset(50, 10), Offset(50, 90)],
  ]),
  'J': const LetterPathData([
    [Offset(65, 10), Offset(65, 70), Offset(60, 85), Offset(45, 90), Offset(30, 85), Offset(22, 72)],
  ]),
  'K': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(80, 10), Offset(20, 50)],
    [Offset(20, 50), Offset(80, 90)],
  ]),
  'L': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 90), Offset(75, 90)],
  ]),
  'M': const LetterPathData([
    [Offset(15, 90), Offset(15, 10), Offset(50, 55), Offset(85, 10), Offset(85, 90)],
  ]),
  'N': const LetterPathData([
    [Offset(20, 90), Offset(20, 10), Offset(80, 90), Offset(80, 10)],
  ]),
  'O': LetterPathData([_ellipse(cx: 50, cy: 50, rx: 35, ry: 40)]),
  'P': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 10), Offset(60, 10), Offset(75, 27), Offset(60, 45), Offset(20, 45)],
  ]),
  'Q': LetterPathData([
    _ellipse(cx: 50, cy: 48, rx: 35, ry: 38),
    const [Offset(58, 62), Offset(85, 92)],
  ]),
  'R': const LetterPathData([
    [Offset(20, 10), Offset(20, 90)],
    [Offset(20, 10), Offset(60, 10), Offset(75, 27), Offset(60, 45), Offset(20, 45)],
    [Offset(45, 45), Offset(80, 90)],
  ]),
  'S': const LetterPathData([
    [
      Offset(76, 22), Offset(60, 11), Offset(40, 11), Offset(25, 20),
      Offset(22, 32), Offset(30, 42), Offset(50, 48), Offset(70, 55),
      Offset(78, 68), Offset(75, 80), Offset(58, 90), Offset(38, 90), Offset(22, 79),
    ],
  ]),
  'T': const LetterPathData([
    [Offset(15, 10), Offset(85, 10)],
    [Offset(50, 10), Offset(50, 90)],
  ]),
  'U': const LetterPathData([
    [Offset(20, 10), Offset(20, 65), Offset(28, 82), Offset(50, 90), Offset(72, 82), Offset(80, 65), Offset(80, 10)],
  ]),
  'V': const LetterPathData([
    [Offset(15, 10), Offset(50, 90), Offset(85, 10)],
  ]),
  'W': const LetterPathData([
    [Offset(10, 10), Offset(30, 90), Offset(50, 50), Offset(70, 90), Offset(90, 10)],
  ]),
  'X': const LetterPathData([
    [Offset(15, 10), Offset(85, 90)],
    [Offset(85, 10), Offset(15, 90)],
  ]),
  'Y': const LetterPathData([
    [Offset(15, 10), Offset(50, 50)],
    [Offset(85, 10), Offset(50, 50)],
    [Offset(50, 50), Offset(50, 90)],
  ]),
  'Z': const LetterPathData([
    [Offset(15, 10), Offset(85, 10)],
    [Offset(85, 10), Offset(15, 90)],
    [Offset(15, 90), Offset(85, 90)],
  ]),
};

/// Placeholder for future lowercase support — same schema as
/// [uppercaseLetterPaths], just empty until lowercase letterforms are authored.
const Map<String, LetterPathData> lowercaseLetterPaths = {};

LetterPathData? letterPathFor(String letter, {bool uppercase = true}) {
  final map = uppercase ? uppercaseLetterPaths : lowercaseLetterPaths;
  final key = uppercase ? letter.toUpperCase() : letter.toLowerCase();
  return map[key];
}

/// Flattens a letter's stroke anchors into densely and evenly spaced points
/// in pixel space for [size], preserving stroke boundaries (each inner list
/// is one continuous pen-down stroke).
List<List<Offset>> densifyStrokes(List<List<Offset>> strokes, Size size, {double spacing = 6}) {
  return strokes.map((anchors) {
    final points = <Offset>[];
    for (var i = 0; i < anchors.length - 1; i++) {
      final a = _toPixels(anchors[i], size);
      final b = _toPixels(anchors[i + 1], size);
      final steps = math.max(1, ((b - a).distance / spacing).round());
      for (var s = 0; s < steps; s++) {
        points.add(Offset.lerp(a, b, s / steps)!);
      }
    }
    if (anchors.isNotEmpty) points.add(_toPixels(anchors.last, size));
    return points;
  }).toList();
}

Offset _toPixels(Offset normalized, Size size) => Offset(normalized.dx / 100 * size.width, normalized.dy / 100 * size.height);

List<Offset> _ellipse({required double cx, required double cy, required double rx, required double ry, int points = 24}) {
  return _arc(cx: cx, cy: cy, rx: rx, ry: ry, startDeg: -90, endDeg: 270, points: points);
}

List<Offset> _arc({
  required double cx,
  required double cy,
  required double rx,
  required double ry,
  required double startDeg,
  required double endDeg,
  int points = 20,
}) {
  final start = startDeg * math.pi / 180;
  final end = endDeg * math.pi / 180;
  return List.generate(points + 1, (i) {
    final angle = start + (end - start) * i / points;
    return Offset(cx + rx * math.cos(angle), cy + ry * math.sin(angle));
  });
}

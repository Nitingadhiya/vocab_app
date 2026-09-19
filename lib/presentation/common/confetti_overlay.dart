import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

/// A one-shot full-screen celebration: a burst of falling confetti/star
/// particles behind a bouncing message card. Used for milestones bigger than
/// a single item finishing (completing a whole category, or all 26 letters),
/// where the small inline "Great job!" toast isn't enough of a payoff.
class ConfettiOverlay {
  ConfettiOverlay._();

  /// [accentColor] ties the confetti and card tint to the screen it's shown
  /// over (e.g. the category's pastel background) so the celebration reads
  /// as part of that screen rather than a mismatched color dropped on top.
  static void celebrate(BuildContext context, {required String title, String? subtitle, Color? accentColor}) {
    final overlay = Overlay.of(context);
    final resolvedAccent = accentColor ?? Theme.of(context).colorScheme.primary;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        title: title,
        subtitle: subtitle,
        accentColor: resolvedAccent,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _CelebrationOverlay extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final VoidCallback onDone;

  const _CelebrationOverlay({
    required this.title,
    this.subtitle,
    required this.accentColor,
    required this.onDone,
  });

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay> with SingleTickerProviderStateMixin {
  static const _particleCount = 36;
  static const _glyphs = ['⭐', '🎉', '✨', '🌟'];

  late final AnimationController _controller;
  late final List<_Particle> _particles;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      });
    final random = math.Random();
    final palette = [
      widget.accentColor,
      Color.lerp(widget.accentColor, Colors.white, 0.55)!,
      const Color(0xFFFFD54F), // gold, reads as "celebration" against any pastel
      Colors.white,
    ];
    _particles = List.generate(_particleCount, (i) => _Particle.random(random, _glyphs, palette));
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      ignoring: true,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(particles: _particles, progress: _controller.value, canvasSize: size),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.i24),
                    child: _MessageCard(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      progress: _controller.value,
                      accentColor: widget.accentColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  // Dark ink on a light card reads well regardless of the accent hue behind
  // it — the same convention CategoryCard uses for its pastel tiles.
  static const _ink = Color(0xFF201C3A);

  final String title;
  final String? subtitle;
  final double progress;
  final Color accentColor;

  const _MessageCard({required this.title, required this.subtitle, required this.progress, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    // Pop in over the first ~25% of the animation, hold, then fade out over
    // the last ~20% so it doesn't just vanish mid-confetti.
    final entrance = Curves.elasticOut.transform((progress / 0.25).clamp(0.0, 1.0));
    final fadeOut = 1 - ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
    // A soft tint of the screen's own accent color, not the raw saturated
    // hue, so the card reads as "part of" the background instead of a
    // clashing sticker dropped on top of it.
    final cardColor = Color.lerp(Colors.white, accentColor, 0.35)!;

    return Opacity(
      opacity: fadeOut,
      child: Transform.scale(
        scale: entrance,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Insets.i24, vertical: Insets.i24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.r24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                SizedBox(height: Insets.i12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppCss.bodySmallSemiBold.size(18).textColor(_ink),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: Insets.i6),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppCss.captionSmall.textColor(_ink.withValues(alpha: 0.7)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One confetti particle's fixed launch parameters — origin/velocity/color
/// are randomized once at creation, then re-evaluated per frame from
/// [progress] alone so the animation stays deterministic across repaints.
class _Particle {
  final double startXFraction;
  final double angle;
  final double speed;
  final double rotationSpeed;
  final double size;
  final String? glyph;
  final Color? color;

  const _Particle({
    required this.startXFraction,
    required this.angle,
    required this.speed,
    required this.rotationSpeed,
    required this.size,
    this.glyph,
    this.color,
  });

  factory _Particle.random(math.Random random, List<String> glyphs, List<Color> palette) {
    final isGlyph = random.nextBool();
    return _Particle(
      startXFraction: random.nextDouble(),
      angle: (random.nextDouble() * 0.5 - 0.25) * math.pi, // mostly upward/outward
      speed: 0.6 + random.nextDouble() * 0.6,
      rotationSpeed: (random.nextDouble() - 0.5) * 8,
      size: isGlyph ? 14 + random.nextDouble() * 10 : 6 + random.nextDouble() * 5,
      glyph: isGlyph ? glyphs[random.nextInt(glyphs.length)] : null,
      color: isGlyph ? null : palette[random.nextInt(palette.length)],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Size canvasSize;

  _ConfettiPainter({required this.particles, required this.progress, required this.canvasSize});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final particle in particles) {
      // Ease-out burst outward from the origin, plus a steady downward drift
      // (gravity) so particles arc up-and-out then fall, like real confetti.
      final t = progress;
      final burst = 1 - math.pow(1 - t, 2);
      final originX = particle.startXFraction * size.width;
      final originY = size.height * 0.4;
      final dx = originX + math.sin(particle.angle) * burst * size.width * 0.4 * particle.speed;
      final dy = originY - math.cos(particle.angle) * burst * size.height * 0.25 * particle.speed + t * t * size.height * 0.6;

      final opacity = 1 - ((t - 0.7) / 0.3).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      if (particle.glyph != null) {
        final painter = TextPainter(
          text: TextSpan(text: particle.glyph, style: TextStyle(fontSize: particle.size)),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(particle.rotationSpeed * t);
        canvas.translate(-painter.width / 2, -painter.height / 2);
        painter.paint(canvas, Offset.zero);
        canvas.restore();
      } else {
        dotPaint.color = particle.color!.withValues(alpha: opacity);
        canvas.drawCircle(Offset(dx, dy), particle.size / 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

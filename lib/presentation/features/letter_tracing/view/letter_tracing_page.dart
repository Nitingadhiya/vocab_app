import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/color_extensions.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';
import 'package:vocab_app/presentation/common/confetti_overlay.dart';
import 'package:vocab_app/presentation/common/dialogs.dart';
import 'package:vocab_app/presentation/common/loading_widget.dart';
import 'package:vocab_app/presentation/common/pager_row.dart';
import 'package:vocab_app/presentation/common/primary_button.dart';
import 'package:vocab_app/presentation/features/letter_tracing/data/letter_paths.dart';
import 'package:vocab_app/presentation/features/letter_tracing/viewmodel/letter_tracing_cubit.dart';

/// A–Z letter-tracing practice: one big dotted guide letter at a time, the
/// child traces it with a finger, and enough coverage of the guide counts
/// as done. Kept separate from [PhonicsCubit]/[PhonicsPage] (letter-sound
/// practice) since tracing needs its own gesture-driven canvas and
/// completion state.
class LetterTracingPage extends StatelessWidget {
  final String letterId;

  const LetterTracingPage({super.key, required this.letterId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<LetterTracingCubit, LetterTracingState>(
      listener: (context, state) {
        if (state is LetterTracingError) {
          showAlertDialog(context: context, body: state.message);
        }
        if (state is LetterTracingLoaded && state.celebrateAll) {
          ConfettiOverlay.celebrate(
            context,
            title: 'You traced all 26 letters!',
            subtitle: 'Amazing work! 🎉',
            accentColor: state.category.colorHex.toColor(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Letter Tracing', style: AppCss.bodyBaseSemibold.textColor(colorScheme.onSurface)),
          ),
          body: state is LetterTracingLoading || state is LetterTracingInitial
              ? const LoadingWidget()
              : state is LetterTracingLoaded
                  ? _TracingContent(state: state)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _TracingContent extends StatelessWidget {
  final LetterTracingLoaded state;

  const _TracingContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<LetterTracingCubit>();
    final letter = state.currentLetter.letter ?? state.currentLetter.text;

    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.i24, Insets.i16, Insets.i24, Insets.i16),
      child: Column(
        children: [
          Text(
            '$letter of ${state.letters.length}',
            style: AppCss.bodySmallSemiBold.textColor(colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          SizedBox(height: Insets.i16),
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: state.category.colorHex.toColor(),
                      borderRadius: BorderRadius.circular(AppRadius.r24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    // Top padding is constant regardless of completion state so the
                    // letter's position never shifts — it just reserves a strip for
                    // the "Great job!" banner that the guide dots never occupy.
                    child: Padding(
                      padding: EdgeInsets.only(top: Sizes.s56),
                      child: _TracingCanvas(
                        key: ValueKey('${state.currentLetter.id}_${state.attempt}'),
                        letter: letter,
                        guideColor: colorScheme.onSurface.withValues(alpha: 0.55),
                        inkColor: colorScheme.primary,
                        onComplete: cubit.markComplete,
                      ),
                    ),
                  ),
                ),
                if (state.isComplete)
                  Positioned(
                    top: Insets.i16,
                    left: 0,
                    right: 0,
                    child: Center(child: const _CompletionBanner()),
                  ),
              ],
            ),
          ),
          SizedBox(height: Insets.i16),
          PrimaryButton(
            label: 'Try Again',
            trailingIcon: Icons.refresh_rounded,
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            onPressed: cubit.retry,
          ),
          SizedBox(height: Insets.i16),
          PagerRow(
            currentIndex: state.currentIndex,
            itemCount: state.letters.length,
            onGoTo: (index) => context.pushReplacement('/phonics/tracing/${state.letters[index].id}'),
          ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Insets.i20, vertical: Insets.i12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.r24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 26)),
            SizedBox(width: Insets.i8),
            Text('Great job!', style: AppCss.bodySmallSemiBold.textColor(colorScheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

/// The touch-tracking surface: draws a dotted guide for [letter], turning
/// each dot from [guideColor] to the traced color as the child's finger
/// covers it — no separate freehand stroke is drawn over the guide, so the
/// letter itself is never obscured. Once every dot is covered, the dots give
/// way to a single smooth [inkColor] stroke along the guide path, reading as
/// the finished letter. Calls [onComplete] once that 100% coverage is
/// reached. Gesture/paint state is local (recreated whenever the widget's
/// key changes, i.e. on a new letter or a retry) rather than routed through
/// the Cubit, since it's high-frequency per-frame data with no reason to
/// survive a rebuild.
class _TracingCanvas extends StatefulWidget {
  final String letter;
  final Color guideColor;
  final Color inkColor;
  final VoidCallback onComplete;

  const _TracingCanvas({
    super.key,
    required this.letter,
    required this.guideColor,
    required this.inkColor,
    required this.onComplete,
  });

  @override
  State<_TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<_TracingCanvas> {
  // Must be 1.0: the letter is only "done" once every guide point has been
  // covered. Firing early (this used to be 0.7) let "Great Job" show for a
  // partially-traced letter.
  static const _completionThreshold = 1.0;
  static const _toleranceFraction = 0.12;
  static const _completionDelay = Duration(milliseconds: 500);

  List<List<Offset>> _guideSamples = const [];
  List<bool> _covered = const [];
  Size? _sizedFor;

  /// Set as soon as a timer is scheduled (not when it fires) so a burst of
  /// pan-update touches at 100% coverage can't schedule [widget.onComplete]
  /// more than once for this attempt.
  bool _completionScheduled = false;
  Timer? _completionTimer;

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  void _ensureGuideFor(Size size) {
    if (_sizedFor == size) return;
    _sizedFor = size;
    final path = letterPathFor(widget.letter);
    _guideSamples = path == null ? const [] : densifyStrokes(path.strokes, size);
    _covered = List.filled(_guideSamples.fold<int>(0, (sum, stroke) => sum + stroke.length), false);
  }

  void _registerTouch(Offset point) {
    if (_covered.isEmpty) return;
    final tolerance = (_sizedFor!.shortestSide) * _toleranceFraction;
    setState(() {
      var i = 0;
      for (final stroke in _guideSamples) {
        for (final guidePoint in stroke) {
          if (!_covered[i] && (guidePoint - point).distance <= tolerance) {
            _covered[i] = true;
          }
          i++;
        }
      }
    });

    if (!_completionScheduled) {
      final coverage = _covered.where((c) => c).length / _covered.length;
      if (coverage >= _completionThreshold) {
        _completionScheduled = true;
        _completionTimer = Timer(_completionDelay, () {
          if (!mounted) return;
          widget.onComplete();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureGuideFor(size);
        return GestureDetector(
          onPanStart: (details) => _registerTouch(details.localPosition),
          onPanUpdate: (details) => _registerTouch(details.localPosition),
          child: CustomPaint(
            size: size,
            painter: _LetterTracePainter(
              guideSamples: _guideSamples,
              covered: _covered,
              guideColor: widget.guideColor,
              inkColor: widget.inkColor,
            ),
          ),
        );
      },
    );
  }
}

class _LetterTracePainter extends CustomPainter {
  static const _dotRadius = 4.5;
  static const _tracedDotColor = Color(0xFF4CAF50);

  final List<List<Offset>> guideSamples;
  final List<bool> covered;
  final Color guideColor;
  final Color inkColor;

  _LetterTracePainter({
    required this.guideSamples,
    required this.covered,
    required this.guideColor,
    required this.inkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Same 100%-coverage condition that drives the completion timer, so the
    // "finished letter" look can never appear before tracing actually
    // completes.
    final fullyCovered = covered.isNotEmpty && !covered.contains(false);

    if (fullyCovered) {
      final tracedPaint = Paint()
        ..color = inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final stroke in guideSamples) {
        if (stroke.isEmpty) continue;
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (final point in stroke.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, tracedPaint);
      }
      return;
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    var i = 0;
    for (final stroke in guideSamples) {
      for (var j = 0; j < stroke.length; j++) {
        if (j % 2 == 0) {
          dotPaint.color = covered[i] ? _tracedDotColor : guideColor;
          canvas.drawCircle(stroke[j], _dotRadius, dotPaint);
        }
        i++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LetterTracePainter oldDelegate) => true;
}

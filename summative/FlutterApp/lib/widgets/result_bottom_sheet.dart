import 'dart:math';
import 'package:flutter/material.dart';

void showResultBottomSheet(BuildContext context, double score) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ResultSheet(score: score),
  );
}

class _ResultSheet extends StatelessWidget {
  final double score;

  const _ResultSheet({required this.score});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    Color gaugeColor;
    IconData icon;

    if (score >= 80) {
      label = 'EXCELLENT';
      gaugeColor = const Color(0xFF4CAF50);
      icon = Icons.emoji_events;
    } else if (score >= 60) {
      label = 'GOOD';
      gaugeColor = const Color(0xFFFFA726);
      icon = Icons.thumb_up;
    } else {
      label = 'NEEDS IMPROVEMENT';
      gaugeColor = const Color(0xFFEF5350);
      icon = Icons.trending_down;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.7,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Animated score gauge
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score.clamp(0, 100)),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedScore, _) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: _ScoreGaugePainter(
                            score: animatedScore,
                            gaugeColor: gaugeColor,
                            trackColor:
                                colorScheme.onSurface.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, color: gaugeColor, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  animatedScore.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: gaugeColor,
                                        fontSize: 40,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Label badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: gaugeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: gaugeColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: gaugeColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'PREDICTED MATH SCORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Based on your profile, you are predicted to score ${score.toStringAsFixed(2)} in math.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  final double score;
  final Color gaugeColor;
  final Color trackColor;

  _ScoreGaugePainter({
    required this.score,
    required this.gaugeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;
    const startAngle = -pi / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Score arc
    final sweepAngle = (score / 100) * 2 * pi;
    final scorePaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreGaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.gaugeColor != gaugeColor;
}

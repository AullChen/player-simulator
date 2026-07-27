import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/weighted_value.dart';
import '../theme/app_theme.dart';

class ProbabilityWheel extends StatelessWidget {
  const ProbabilityWheel({
    super.key,
    required this.animation,
    required this.segments,
    required this.selectedValue,
  });

  final Animation<double> animation;
  final List<WeightedValue<String>> segments;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curved = Curves.easeOutCubic.transform(animation.value);
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Transform.rotate(
                angle: _targetRotation() * curved,
                child: CustomPaint(
                  size: const Size.square(270),
                  painter: _WheelPainter(segments, Directionality.of(context)),
                ),
              ),
            ),
            const Icon(Icons.change_history, color: AppColors.gold, size: 38),
            Positioned(
              top: 119,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 4),
                  boxShadow: const [
                    BoxShadow(blurRadius: 16, color: Color(0x33000000)),
                  ],
                ),
                child: const Icon(Icons.sports_soccer, color: AppColors.navy),
              ),
            ),
          ],
        );
      },
    );
  }

  double _targetRotation() {
    final total = segments.fold<int>(0, (sum, segment) => sum + segment.weight);
    var before = 0;
    var selectedWeight = segments.first.weight;
    for (final segment in segments) {
      if (segment.value == selectedValue) {
        selectedWeight = segment.weight;
        break;
      }
      before += segment.weight;
    }
    final selectedCenter =
        -math.pi / 2 + math.pi * 2 * (before + selectedWeight / 2) / total;
    return math.pi * 12 + (-math.pi / 2 - selectedCenter);
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.segments, this.textDirection);

  final List<WeightedValue<String>> segments;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final total = segments.fold<int>(0, (sum, segment) => sum + segment.weight);
    const colors = [
      AppColors.pitchDark,
      AppColors.navySoft,
      Color(0xFF1B8B75),
      Color(0xFF244E68),
      Color(0xFFC09449),
      Color(0xFF0A6F58),
      Color(0xFF355D74),
      Color(0xFFB1783E),
    ];
    var cursor = -math.pi / 2;

    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      final sweep = math.pi * 2 * segment.weight / total;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        cursor,
        sweep,
        true,
        paint,
      );

      if (sweep >= 0.18) {
        final label = segment.value.length > 10
            ? '${segment.value.substring(0, 9)}…'
            : segment.value;
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: textDirection,
        )..layout(maxWidth: radius * 0.62);
        final angle = cursor + sweep / 2;
        final position =
            center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.68;
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(angle + math.pi / 2);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
      cursor += sweep;
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    if (oldDelegate.textDirection != textDirection ||
        oldDelegate.segments.length != segments.length) {
      return true;
    }
    for (var index = 0; index < segments.length; index++) {
      if (oldDelegate.segments[index].value != segments[index].value ||
          oldDelegate.segments[index].weight != segments[index].weight) {
        return true;
      }
    }
    return false;
  }
}

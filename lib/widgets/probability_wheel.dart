import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProbabilityWheel extends StatelessWidget {
  const ProbabilityWheel({
    super.key,
    required this.animation,
    required this.labels,
  });

  final Animation<double> animation;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Transform.rotate(
                angle: animation.value * math.pi * 8,
                child: CustomPaint(
                  size: const Size.square(270),
                  painter: _WheelPainter(labels),
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
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.labels);

  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final sweep = math.pi * 2 / labels.length;
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

    for (var index = 0; index < labels.length; index++) {
      final start = -math.pi / 2 + index * sweep;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.58);
      final angle = start + sweep / 2;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.67;
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
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
    return oldDelegate.labels != labels;
  }
}

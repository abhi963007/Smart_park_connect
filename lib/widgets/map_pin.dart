import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A reusable Google Maps-style red teardrop pin widget.
class MapPin extends StatelessWidget {
  final double size;
  final Color color;

  const MapPin({
    super.key,
    this.size = 44,
    this.color = const Color(0xFFEA4335),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Subtle ground shadow
        Container(
          width: size * 0.32,
          height: size * 0.11,
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.all(Radius.elliptical(size * 0.32, size * 0.11)),
          ),
        ),
        // The iconic Google-like Pin
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: CustomPaint(
            size: Size(size * 0.68, size * 0.95),
            painter: _MapPinPainter(color: color),
          ),
        ),
      ],
    );
  }
}

class _MapPinPainter extends CustomPainter {
  final Color color;

  _MapPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final pinWidth = size.width;
    final pinRadius = pinWidth / 2;
    final pinCenterY = pinRadius;
    final tipY = size.height;

    final darkColor = Color.lerp(color, Colors.black, 0.2)!;

    final path = ui.Path();
    path.moveTo(cx, tipY);

    path.cubicTo(
      cx - pinRadius * 0.9, tipY * 0.75,
      cx - pinRadius, pinCenterY + pinRadius * 0.5,
      cx - pinRadius, pinCenterY,
    );

    path.arcTo(
      Rect.fromCircle(center: Offset(cx, pinCenterY), radius: pinRadius),
      3.14159,
      3.14159,
      false,
    );

    path.cubicTo(
      cx + pinRadius, pinCenterY + pinRadius * 0.5,
      cx + pinRadius * 0.9, tipY * 0.75,
      cx, tipY,
    );
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.35), 4, true);

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, 0),
        Offset(cx, tipY),
        [color, darkColor],
      );
    canvas.drawPath(path, paint);

    final dotRadius = pinRadius * 0.38;
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, pinCenterY), dotRadius, dotPaint);

    final dotShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, pinCenterY), dotRadius, dotShadowPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, pinCenterY), radius: pinRadius - 1),
      -2.5,
      1.4,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

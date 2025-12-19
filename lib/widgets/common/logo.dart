import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;
  final String? className;

  const Logo({
    super.key,
    this.size = 32,
    this.className,
  });

  const Logo.small({super.key}) : size = 24, className = null;
  const Logo.medium({super.key}) : size = 32, className = null;
  const Logo.large({super.key}) : size = 40, className = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(isDark: isDark),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final bool isDark;

  _LogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB); // blue-400/blue-600

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isDark ? Colors.grey[300]! : Colors.grey[700]!;

    final greenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A); // green-400/green-600

    final scale = size.width / 32;
    
    // Shopping cart body
    final cartPath = Path()
      ..moveTo(8 * scale, 8 * scale)
      ..lineTo(28 * scale, 8 * scale)
      ..lineTo(26.5 * scale, 17 * scale)
      ..lineTo(9.5 * scale, 17 * scale)
      ..lineTo(8 * scale, 8 * scale);
    canvas.drawPath(cartPath, paint);

    final handlePath = Path()
      ..moveTo(8 * scale, 8 * scale)
      ..lineTo(6.5 * scale, 5 * scale)
      ..lineTo(3 * scale, 5 * scale);
    canvas.drawPath(handlePath, strokePaint);

    canvas.drawCircle(Offset(12 * scale, 24 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(22 * scale, 24 * scale), 2 * scale, paint);

    final checkPath = Path()
      ..moveTo(6 * scale, 12 * scale)
      ..lineTo(9 * scale, 15 * scale)
      ..lineTo(15 * scale, 9 * scale);
    canvas.drawPath(checkPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// DICE PAINTER - draws beautiful dice using Canvas
// ─────────────────────────────────────────

class DicePainter extends CustomPainter {
  final int value;
  final DiceStyle style;

  DicePainter({required this.value, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pad = w * 0.06;
    final radius = Radius.circular(w * style.borderRadius);
    final rect = RRect.fromLTRBR(pad, pad, w - pad, h - pad, radius);

    // ── Shadow ──
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(
      RRect.fromLTRBR(pad + 6, pad + 10, w - pad + 6, h - pad + 10, radius),
      shadowPaint,
    );

    // ── Body top ──
    final bodyPaint = Paint()..color = style.bgColor;
    canvas.drawRRect(rect, bodyPaint);

    // ── Body bottom (darker) ──
    final bottomRect = RRect.fromLTRBR(
        pad, h / 2, w - pad, h - pad, radius);
    final bottomPaint = Paint()..color = style.bgColor2;
    canvas.drawRRect(bottomRect, bottomPaint);

    // ── Top shine ──
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(style.shineOpacity);
    final shineRect = RRect.fromLTRBR(pad, pad, w - pad, h / 2 + h * 0.1, radius);
    canvas.drawRRect(shineRect, shinePaint);

    // ── Border ──
    final borderPaint = Paint()
      ..color = style.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawRRect(rect, borderPaint);

    // ── Dots ──
    _drawDots(canvas, size);
  }

  void _drawDots(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    final cy = size.height / 2;
    final off = w * 0.27;
    final r = w * 0.09;

    final positions = _dotPositions(cx, cy, off);

    for (final pos in positions) {
      // dot shadow
      final shadowPaint = Paint()
        ..color = style.dotColor.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(pos.dx + 2, pos.dy + 3), r, shadowPaint);

      // dot body
      final dotPaint = Paint()..color = style.dotColor;
      canvas.drawCircle(pos, r, dotPaint);

      // dot highlight
      final highlightPaint = Paint()
        ..color = style.dotHighlight.withOpacity(0.6);
      canvas.drawCircle(Offset(pos.dx - r * 0.3, pos.dy - r * 0.35), r * 0.38, highlightPaint);
    }
  }

  List<Offset> _dotPositions(double cx, double cy, double off) {
    switch (value) {
      case 1:
        return [Offset(cx, cy)];
      case 2:
        return [Offset(cx - off, cy - off), Offset(cx + off, cy + off)];
      case 3:
        return [Offset(cx - off, cy - off), Offset(cx, cy), Offset(cx + off, cy + off)];
      case 4:
        return [
          Offset(cx - off, cy - off), Offset(cx + off, cy - off),
          Offset(cx - off, cy + off), Offset(cx + off, cy + off),
        ];
      case 5:
        return [
          Offset(cx - off, cy - off), Offset(cx + off, cy - off),
          Offset(cx, cy),
          Offset(cx - off, cy + off), Offset(cx + off, cy + off),
        ];
      case 6:
        return [
          Offset(cx - off, cy - off), Offset(cx + off, cy - off),
          Offset(cx - off, cy), Offset(cx + off, cy),
          Offset(cx - off, cy + off), Offset(cx + off, cy + off),
        ];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.style != style;
}

// ─────────────────────────────────────────
// DICE STYLE MODEL
// ─────────────────────────────────────────
class DiceStyle {
  final Color bgColor;
  final Color bgColor2;
  final Color borderColor;
  final Color dotColor;
  final Color dotHighlight;
  final double borderRadius;
  final double shineOpacity;

  const DiceStyle({
    required this.bgColor,
    required this.bgColor2,
    required this.borderColor,
    required this.dotColor,
    required this.dotHighlight,
    this.borderRadius = 0.18,
    this.shineOpacity = 0.22,
  });
}

// ─────────────────────────────────────────
// PREDEFINED STYLES
// ─────────────────────────────────────────
class DiceStyles {
  static const mintFresh = DiceStyle(
    bgColor: Color(0xFFDCFCE7),
    bgColor2: Color(0xFFA7F3D0),
    borderColor: Color(0xFF059669),
    dotColor: Color(0xFF065F46),
    dotHighlight: Color(0xFFFFFFFF),
    borderRadius: 0.15,
  );

  static const whiteClean = DiceStyle(
    bgColor: Color(0xFFFFFFFF),
    bgColor2: Color(0xFFF3F4F6),
    borderColor: Color(0xFFD1D5DB),
    dotColor: Color(0xFF111827),
    dotHighlight: Color(0xFFFFFFFF),
    borderRadius: 0.14,
    shineOpacity: 0.0,
  );

  static const rose = DiceStyle(
    bgColor: Color(0xFFFFF1F2),
    bgColor2: Color(0xFFFECDD3),
    borderColor: Color(0xFFE11D48),
    dotColor: Color(0xFF9F1239),
    dotHighlight: Color(0xFFFFFFFF),
    borderRadius: 0.18,
  );

  static const darkAmber = DiceStyle(
    bgColor: Color(0xFF1C1917),
    bgColor2: Color(0xFF0C0A09),
    borderColor: Color(0xFFD97706),
    dotColor: Color(0xFFFBBF24),
    dotHighlight: Color(0xFFFEF3C7),
    borderRadius: 0.18,
  );

  static const darkLuxury = DiceStyle(
    bgColor: Color(0xFF1E1B4B),
    bgColor2: Color(0xFF0F0E2E),
    borderColor: Color(0xFF8B5CF6),
    dotColor: Color(0xFFA78BFA),
    dotHighlight: Color(0xFFEDE9FE),
    borderRadius: 0.20,
  );
}

// ─────────────────────────────────────────
// DICE WIDGET
// ─────────────────────────────────────────
class DiceWidget extends StatelessWidget {
  final int value;
  final DiceStyle style;
  final double size;

  const DiceWidget({
    super.key,
    required this.value,
    required this.style,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DicePainter(value: value, style: style),
      ),
    );
  }
}
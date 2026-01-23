import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bubble.dart';
import 'water_bottle.dart';
import 'wave.dart';
import 'water_container.dart';

class TriangularBottle extends StatefulWidget {
  /// Color of the water
  final Color waterColor;

  /// Color of the bottle
  final Color bottleColor;

  /// Color of the bottle cap
  final Color capColor;
  TriangularBottle({
    Key? key,
    this.waterColor = Colors.blue,
    this.bottleColor = Colors.blue,
    this.capColor = Colors.blueGrey,
  }) : super(key: key);
  @override
  TriangularBottleState createState() => TriangularBottleState();
}

class TriangularBottleState extends State<TriangularBottle>
    with TickerProviderStateMixin, WaterContainer {
  @override
  void initState() {
    super.initState();
    initWater(widget.waterColor, this);
  }

  @override
  void dispose() {
    disposeWater();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: TriangularBottleStatePainter(
              repaint: waves.isNotEmpty ? waves.first.animation : null,
              waves: waves,
              bubbles: bubbles,
              waterLevel: waterLevel,
              bottleColor: widget.bottleColor,
              capColor: widget.capColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TriangularBottleStatePainter extends WaterBottlePainter {
  static const BREAK_POINT = 1.2;

  Shader? _cachedRadialShader;
  Path? _cachedTriangularBottlePath;
  Path? _cachedTriangularMaskPath;
  Path? _cachedTriangularCapPath;

  TriangularBottleStatePainter({
    Listenable? repaint,
    required List<WaveLayer> waves,
    required List<Bubble> bubbles,
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
  }) : super(
         repaint: repaint,
         waves: waves,
         bubbles: bubbles,
         waterLevel: waterLevel,
         bottleColor: bottleColor,
         capColor: capColor,
       );

  @override
  void paint(Canvas canvas, Size size) {
    if (cachedSize != size) {
      _cachedTriangularBottlePath = null;
      _cachedTriangularMaskPath = null;
      _cachedTriangularCapPath = null;
    }
    super.paint(canvas, size);
  }

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    if (_cachedTriangularBottlePath == null) {
      final r = math.min(size.width, size.height);
      final neckTop = size.width * 0.1;
      final neckBottom = size.height - r + 3;
      final neckRingOuter = size.width * 0.28;
      final neckRingOuterR = size.width - neckRingOuter;
      final neckRingInner = size.width * 0.35;
      final neckRingInnerR = size.width - neckRingInner;
      final bodyBottom = size.height;
      final bodyL = 0.0;
      final bodyR = size.width;
      _cachedTriangularBottlePath = Path();
      _cachedTriangularBottlePath!.moveTo(neckRingOuter, neckTop);
      _cachedTriangularBottlePath!.lineTo(neckRingInner, neckTop);
      _cachedTriangularBottlePath!.lineTo(neckRingInner, neckBottom);
      final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
      final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
      final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
      final bodyLBY = bodyBottom;
      final bodyRAX = size.width - bodyLAX;
      final bodyRAY = bodyLAY;
      final bodyRBX = size.width - bodyLBX;
      final bodyRBY = bodyLBY;
      _cachedTriangularBottlePath!.lineTo(bodyLAX, bodyLAY);
      _cachedTriangularBottlePath!.conicTo(
        bodyL,
        bodyBottom,
        bodyLBX,
        bodyLBY,
        1,
      );
      _cachedTriangularBottlePath!.lineTo(bodyRBX, bodyRBY);
      _cachedTriangularBottlePath!.conicTo(
        bodyR,
        bodyBottom,
        bodyRAX,
        bodyRAY,
        1,
      );
      _cachedTriangularBottlePath!.lineTo(neckRingInnerR, neckBottom);
      _cachedTriangularBottlePath!.lineTo(neckRingInnerR, neckTop);
      _cachedTriangularBottlePath!.lineTo(neckRingOuterR, neckTop);
    }
    canvas.drawPath(_cachedTriangularBottlePath!, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    if (_cachedTriangularMaskPath == null) {
      final r = math.min(size.width, size.height);
      final neckTop = size.width * 0.1;
      final neckBottom = size.height - r + 3;
      final neckRingInner = size.width * 0.35 + 5;
      final neckRingInnerR = size.width - neckRingInner;
      final bodyBottom = size.height - 5;
      final bodyL = 5.0;
      final bodyR = size.width - 5;
      _cachedTriangularMaskPath = Path();
      _cachedTriangularMaskPath!.moveTo(neckRingInner, neckTop);
      _cachedTriangularMaskPath!.lineTo(neckRingInner, neckBottom);
      final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
      final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
      final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
      final bodyLBY = bodyBottom;
      final bodyRAX = size.width - bodyLAX;
      final bodyRAY = bodyLAY;
      final bodyRBX = size.width - bodyLBX;
      final bodyRBY = bodyLBY;
      _cachedTriangularMaskPath!.lineTo(bodyLAX, bodyLAY);
      _cachedTriangularMaskPath!.conicTo(
        bodyL,
        bodyBottom,
        bodyLBX,
        bodyLBY,
        1,
      );
      _cachedTriangularMaskPath!.lineTo(bodyRBX, bodyRBY);
      _cachedTriangularMaskPath!.conicTo(
        bodyR,
        bodyBottom,
        bodyRAX,
        bodyRAY,
        1,
      );
      _cachedTriangularMaskPath!.lineTo(neckRingInnerR, neckBottom);
      _cachedTriangularMaskPath!.lineTo(neckRingInnerR, neckTop);
      _cachedTriangularMaskPath!.close();
    }
    canvas.drawPath(_cachedTriangularMaskPath!, paint);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final rect = Offset(0, size.height - r) & size;

    if (_cachedRadialShader == null || cachedSize != size) {
      _cachedRadialShader = RadialGradient(
        center: Alignment.center,
        colors: [Colors.white.withAlpha(120), Colors.white.withAlpha(0)],
      ).createShader(rect);
    }

    paint.color = Colors.white;
    paint.shader = _cachedRadialShader;
    paint.style = PaintingStyle.fill;
    // gradient
    canvas.drawRect(
      Rect.fromLTRB(5, size.height - r + 3, size.width - 5, size.height - 5),
      paint,
    );
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < BREAK_POINT) {
      return;
    }
    if (_cachedTriangularCapPath == null) {
      final capTop = 0.0;
      final capBottom = size.width * 0.2;
      final capMid = (capBottom - capTop) / 2;
      final capL = size.width * 0.33 + 5;
      final capR = size.width - capL;
      final neckRingInner = size.width * 0.35 + 5;
      final neckRingInnerR = size.width - neckRingInner;
      _cachedTriangularCapPath = Path();
      _cachedTriangularCapPath!.moveTo(capL, capTop);
      _cachedTriangularCapPath!.lineTo(neckRingInner, capMid);
      _cachedTriangularCapPath!.lineTo(neckRingInner, capBottom);
      _cachedTriangularCapPath!.lineTo(neckRingInnerR, capBottom);
      _cachedTriangularCapPath!.lineTo(neckRingInnerR, capMid);
      _cachedTriangularCapPath!.lineTo(capR, capTop);
      _cachedTriangularCapPath!.close();
    }
    canvas.drawPath(_cachedTriangularCapPath!, paint);
  }
}

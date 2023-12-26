import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bubble.dart';
import 'water_bottle.dart';
import 'water_container.dart';
import 'wave.dart';

class SphericalBottle extends StatefulWidget {
  /// Color of the water
  final Color waterColor;

  /// Color of the bottle
  final Color bottleColor;

  /// Color of the bottle cap
  final Color capColor;

  /// Create a spherical bottle, you can customize it's part with
  /// [waterColor], [bottleColor], [capColor].
  /// Note that if the width/height ratio get small enough,
  /// the bottle will automatically reduce it's neck
  SphericalBottle(
      {Key? key,
      this.waterColor = Colors.blue,
      this.bottleColor = Colors.blue,
      this.capColor = Colors.blueGrey})
      : super(key: key);
  @override
  SphericalBottleState createState() => SphericalBottleState();
}

class SphericalBottleState extends State<SphericalBottle>
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
    final painter = SphericalBottlePainter(
      repaint: waves.first.animation,
      waves: waves,
      bubbles: bubbles,
      waterLevel: waterLevel,
      bottleColor: widget.bottleColor,
      capColor: widget.capColor,
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: painter,
          ),
        ),
      ],
    );
  }
}

class SphericalBottlePainter extends WaterBottlePainter {
  // At which point should we cut off the neck of the bottle
  static const BREAK_POINT = 1.2;
  SphericalBottlePainter({
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
  void paintEmptyBottle(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height);
    if (size.height / size.width < BREAK_POINT) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height - r / 2), r / 2, brushBottle);
      return;
    }
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingOuter = size.width * 0.28;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.moveTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, brushBottle);
    canvas.drawArc(Rect.fromLTRB(0, size.height - r, size.width, size.height),
        math.pi * 1.59, math.pi * 1.82, false, brushBottle);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height);
    canvas.drawCircle(Offset(size.width / 2, size.height - r / 2), r / 2 - 5,
        brushBottleMask);
    if (size.height / size.width < BREAK_POINT) {
      return;
    }
    final neckTop = size.width * 0.1;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(neckRingInner + 5, neckTop, neckRingInnerR - 5,
            size.height - r / 2),
        brushBottleMask);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height);
    final rect = Offset(0, size.height - r) & size;
    final gradient = RadialGradient(
      center: Alignment.center, // near the top right
      colors: [
        Colors.white.withAlpha(120),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    brushGlossy.color = Colors.white;
    brushGlossy.shader = gradient;
    // gradient
    canvas.drawRect(
        Rect.fromLTRB(5, size.height - r + 3, size.width - 5, size.height - 5),
        brushGlossy);
    // highlight
    brushGlossy.shader = null;
    brushGlossy.color = Colors.white.withAlpha(30);
    brushGlossy.style = PaintingStyle.stroke;
    const HIGHLIGHT_WIDTH = 0.1;
    brushGlossy.strokeWidth = r * HIGHLIGHT_WIDTH;
    const HIGHLIGHT_OFFSET = 0.1;
    final delta = r * HIGHLIGHT_OFFSET;
    canvas.drawArc(
        Rect.fromLTRB(delta, size.height - r + delta, size.width - delta,
            size.height - delta),
        math.pi * 0.8,
        math.pi * 0.4,
        false,
        brushGlossy);
    canvas.drawArc(
        Rect.fromLTRB(delta, size.height - r + delta, size.width - delta,
            size.height - delta),
        math.pi * 1.25,
        math.pi * 0.1,
        false,
        brushGlossy);
  }

  @override
  void paintCap(Canvas canvas, Size size) {
    if (size.height / size.width < BREAK_POINT) {
      return;
    }
    final capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.33 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(capL, capTop);
    path.lineTo(neckRingInner, capMid);
    path.lineTo(neckRingInner, capBottom);
    path.lineTo(neckRingInnerR, capBottom);
    path.lineTo(neckRingInnerR, capMid);
    path.lineTo(capR, capTop);
    path.close();
    canvas.drawPath(path, brushCap);
  }
}

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
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: SphericalBottlePainter(
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

class SphericalBottlePainter extends WaterBottlePainter {
  // At which point should we cut off the neck of the bottle
  static const BREAK_POINT = 1.2;

  Shader? _cachedRadialShader;

  // Cached paths for spherical bottle
  Path? _cachedSphericalBottlePath;
  Path? _cachedSphericalMaskPath;
  Path? _cachedSphericalCapPath;

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
  void paint(Canvas canvas, Size size) {
    if (cachedSize != size) {
      _cachedSphericalBottlePath = null;
      _cachedSphericalMaskPath = null;
      _cachedSphericalCapPath = null;
    }
    super.paint(canvas, size);
  }

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    if (_cachedSphericalBottlePath == null) {
      final r = math.min(size.width, size.height);
      _cachedSphericalBottlePath = Path();
      if (size.height / size.width < BREAK_POINT) {
        _cachedSphericalBottlePath!.addOval(Rect.fromCircle(
            center: Offset(size.width / 2, size.height - r / 2), radius: r / 2));
      } else {
        final neckTop = size.width * 0.1;
        final neckBottom = size.height - r + 3;
        final neckRingOuter = size.width * 0.28;
        final neckRingOuterR = size.width - neckRingOuter;
        final neckRingInner = size.width * 0.35;
        final neckRingInnerR = size.width - neckRingInner;
        _cachedSphericalBottlePath!.moveTo(neckRingOuter, neckTop);
        _cachedSphericalBottlePath!.lineTo(neckRingInner, neckTop);
        _cachedSphericalBottlePath!.lineTo(neckRingInner, neckBottom);
        _cachedSphericalBottlePath!.moveTo(neckRingInnerR, neckBottom);
        _cachedSphericalBottlePath!.lineTo(neckRingInnerR, neckTop);
        _cachedSphericalBottlePath!.lineTo(neckRingOuterR, neckTop);
        _cachedSphericalBottlePath!.addArc(
            Rect.fromLTRB(0, size.height - r, size.width, size.height),
            math.pi * 1.59,
            math.pi * 1.82);
      }
    }
    canvas.drawPath(_cachedSphericalBottlePath!, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    if (_cachedSphericalMaskPath == null) {
      final r = math.min(size.width, size.height);
      _cachedSphericalMaskPath = Path();
      _cachedSphericalMaskPath!.addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height - r / 2),
          radius: r / 2 - 5));
      if (size.height / size.width >= BREAK_POINT) {
        final neckTop = size.width * 0.1;
        final neckRingInner = size.width * 0.35;
        final neckRingInnerR = size.width - neckRingInner;
        _cachedSphericalMaskPath!.addRect(Rect.fromLTRB(
            neckRingInner + 5, neckTop, neckRingInnerR - 5, size.height - r / 2));
      }
    }
    canvas.drawPath(_cachedSphericalMaskPath!, paint);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final rect = Offset(0, size.height - r) & size;

    if (_cachedRadialShader == null || cachedSize != size) {
      _cachedRadialShader = RadialGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withAlpha(120),
          Colors.white.withAlpha(0),
        ],
      ).createShader(rect);
    }

    paint.color = Colors.white;
    paint.shader = _cachedRadialShader;
    paint.style = PaintingStyle.fill;
    // gradient
    canvas.drawRect(
        Rect.fromLTRB(5, size.height - r + 3, size.width - 5, size.height - 5),
        paint);
    // highlight
    paint.shader = null;
    paint.color = Colors.white.withAlpha(30);
    paint.style = PaintingStyle.stroke;
    const HIGHLIGHT_WIDTH = 0.1;
    paint.strokeWidth = r * HIGHLIGHT_WIDTH;
    const HIGHLIGHT_OFFSET = 0.1;
    final delta = r * HIGHLIGHT_OFFSET;
    canvas.drawArc(
        Rect.fromLTRB(delta, size.height - r + delta, size.width - delta,
            size.height - delta),
        math.pi * 0.8,
        math.pi * 0.4,
        false,
        paint);
    canvas.drawArc(
        Rect.fromLTRB(delta, size.height - r + delta, size.width - delta,
            size.height - delta),
        math.pi * 1.25,
        math.pi * 0.1,
        false,
        paint);
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < BREAK_POINT) {
      return;
    }
    if (_cachedSphericalCapPath == null) {
      final capTop = 0.0;
      final capBottom = size.width * 0.2;
      final capMid = (capBottom - capTop) / 2;
      final capL = size.width * 0.33 + 5;
      final capR = size.width - capL;
      final neckRingInner = size.width * 0.35 + 5;
      final neckRingInnerR = size.width - neckRingInner;
      _cachedSphericalCapPath = Path();
      _cachedSphericalCapPath!.moveTo(capL, capTop);
      _cachedSphericalCapPath!.lineTo(neckRingInner, capMid);
      _cachedSphericalCapPath!.lineTo(neckRingInner, capBottom);
      _cachedSphericalCapPath!.lineTo(neckRingInnerR, capBottom);
      _cachedSphericalCapPath!.lineTo(neckRingInnerR, capMid);
      _cachedSphericalCapPath!.lineTo(capR, capTop);
      _cachedSphericalCapPath!.close();
    }
    canvas.drawPath(_cachedSphericalCapPath!, paint);
  }
}

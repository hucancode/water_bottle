import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'water_container.dart';
import 'wave.dart';
import 'bubble.dart';

class WaterBottle extends StatefulWidget {
  /// Color of the water
  final Color waterColor;

  /// Color of the bottle
  final Color bottleColor;

  /// Color of the bottle cap
  final Color capColor;

  /// Create a regular bottle, you can customize it's part with
  /// [waterColor], [bottleColor], [capColor].
  WaterBottle(
      {Key? key,
      this.waterColor = Colors.blue,
      this.bottleColor = Colors.blue,
      this.capColor = Colors.blueGrey})
      : super(key: key);
  @override
  WaterBottleState createState() => WaterBottleState();
}

class WaterBottleState extends State<WaterBottle>
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
            painter: WaterBottlePainter(
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

class WaterBottlePainter extends CustomPainter {
  /// Holds all wave object instances
  final List<WaveLayer> waves;

  /// Holds all bubble object instances
  final List<Bubble> bubbles;

  /// Water level, 0 = no water, 1 = full water
  final waterLevel;

  /// Bottle color
  final bottleColor;

  /// Bottle cap color
  final capColor;

  final Paint _bottlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _maskPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  final Paint _wavePaint = Paint()
    ..blendMode = BlendMode.srcIn
    ..style = PaintingStyle.fill;
  final Paint _bubblePaint = Paint()
    ..blendMode = BlendMode.srcATop
    ..style = PaintingStyle.fill;
  final Paint _glossyPaint = Paint()
    ..blendMode = BlendMode.srcATop
    ..style = PaintingStyle.fill;
  final Paint _capPaint = Paint()
    ..blendMode = BlendMode.srcATop
    ..style = PaintingStyle.fill;

  @protected
  Size? cachedSize;
  Shader? _cachedGlossyShader;
  Path? _cachedBottlePath;
  Path? _cachedMaskPath;
  Path? _cachedCapPath;
  final Matrix4 _transformMatrix = Matrix4.identity();

  WaterBottlePainter(
      {Listenable? repaint,
      required this.waves,
      required this.bubbles,
      required this.waterLevel,
      required this.bottleColor,
      required this.capColor})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (cachedSize != size) {
      cachedSize = size;
      _cachedGlossyShader = null;
      _cachedBottlePath = null;
      _cachedMaskPath = null;
      _cachedCapPath = null;
    }

    _bottlePaint.color = bottleColor;
    paintEmptyBottle(canvas, size, _bottlePaint);

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.saveLayer(rect, _maskPaint);
    paintBottleMask(canvas, size, _maskPaint);

    paintWaves(canvas, size, _wavePaint);

    paintBubbles(canvas, size, _bubblePaint);

    paintGlossyOverlay(canvas, size, _glossyPaint);

    canvas.restore();

    _capPaint.color = capColor;
    paintCap(canvas, size, _capPaint);
  }

  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    if (_cachedBottlePath == null) {
      final neckTop = size.width * 0.1;
      final neckBottom = size.height;
      final neckRingOuter = 0.0;
      final neckRingOuterR = size.width - neckRingOuter;
      final neckRingInner = size.width * 0.1;
      final neckRingInnerR = size.width - neckRingInner;
      _cachedBottlePath = Path();
      _cachedBottlePath!.moveTo(neckRingOuter, neckTop);
      _cachedBottlePath!.lineTo(neckRingInner, neckTop);
      _cachedBottlePath!.lineTo(neckRingInner, neckBottom);
      _cachedBottlePath!.lineTo(neckRingInnerR, neckBottom);
      _cachedBottlePath!.lineTo(neckRingInnerR, neckTop);
      _cachedBottlePath!.lineTo(neckRingOuterR, neckTop);
    }
    canvas.drawPath(_cachedBottlePath!, paint);
  }

  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    if (_cachedMaskPath == null) {
      final neckRingInner = size.width * 0.1;
      final neckRingInnerR = size.width - neckRingInner;
      _cachedMaskPath = Path();
      _cachedMaskPath!.addRect(
          Rect.fromLTRB(
              neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5));
    }
    canvas.drawPath(_cachedMaskPath!, paint);
  }

  void paintWaves(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < waves.length; i++) {
      final wave = waves[i];
      paint.color = wave.color;
      final desiredW = 15 * size.width;
      final desiredH = 0.1 * size.height;
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.bounds.width;
      final scaleY = desiredH / wave.bounds.height;
      final translateX = -wave.offset * translateRange;
      final waterRange = size.height +
          desiredH; // 0 = no water = size.height; 1 = full water = -size.width
      final translateY = (1.0 - waterLevel) * waterRange - desiredH;

      // Use canvas transforms instead of path transforms to avoid allocations
      canvas.save();
      _transformMatrix.setIdentity();
      _transformMatrix.translate(translateX, translateY);
      _transformMatrix.scale(scaleX, scaleY);
      canvas.transform(_transformMatrix.storage);
      canvas.drawPath(wave.svgData, paint);
      canvas.restore();

      if (i != waves.length - 1) {
        continue;
      }
      final gap = size.height - desiredH - translateY;
      if (gap > 0) {
        canvas.drawRect(
            Rect.fromLTRB(0, desiredH + translateY, size.width, size.height),
            paint);
      }
    }
  }

  void paintBubbles(Canvas canvas, Size size, Paint paint) {
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      final offset = Offset(
          bubble.x * size.width, (bubble.y + 1.0 - waterLevel) * size.height);
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    paint.shader = null;
    paint.color = Colors.white.withAlpha(20);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width * 0.5, size.height), paint);
    paint.color = Colors.white.withAlpha(80);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.9, 0, size.width * 0.95, size.height),
        paint);

    _cachedGlossyShader ??= LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withAlpha(180),
        Colors.white.withAlpha(0),
      ],
    ).createShader(Offset.zero & size);

    paint.color = Colors.white;
    paint.shader = _cachedGlossyShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (_cachedCapPath == null) {
      final capTop = 0.0;
      final capBottom = size.width * 0.2;
      final capMid = (capBottom - capTop) / 2;
      final capL = size.width * 0.08 + 5;
      final capR = size.width - capL;
      final neckRingInner = size.width * 0.1 + 5;
      final neckRingInnerR = size.width - neckRingInner;
      _cachedCapPath = Path();
      _cachedCapPath!.moveTo(capL, capTop);
      _cachedCapPath!.lineTo(neckRingInner, capMid);
      _cachedCapPath!.lineTo(neckRingInner, capBottom);
      _cachedCapPath!.lineTo(neckRingInnerR, capBottom);
      _cachedCapPath!.lineTo(neckRingInnerR, capMid);
      _cachedCapPath!.lineTo(capR, capTop);
      _cachedCapPath!.close();
    }
    canvas.drawPath(_cachedCapPath!, paint);
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) =>
      waterLevel != oldDelegate.waterLevel ||
      bottleColor != oldDelegate.bottleColor ||
      capColor != oldDelegate.capColor ||
      waves != oldDelegate.waves ||
      bubbles != oldDelegate.bubbles;
}

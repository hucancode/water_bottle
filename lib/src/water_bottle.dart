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
    final painter = WaterBottlePainter(
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

class WaterBottlePainter extends CustomPainter {
  int repaintCount = 0;
  var lastPaintTimestamp = DateTime.now();
  final brushBottle = Paint();
  final brushBottleMask = Paint();
  final brushWave = Paint();
  final brushBubble = Paint();
  final brushGlossy = Paint();
  final brushCap = Paint();

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

  WaterBottlePainter(
      {Listenable? repaint,
      required this.waves,
      required this.bubbles,
      required this.waterLevel,
      required this.bottleColor,
      required this.capColor})
      : super(repaint: repaint) {
    brushBottle.color = bottleColor;
    brushBottle.style = PaintingStyle.stroke;
    brushBottle.strokeWidth = 3;
    brushBottleMask.color = Colors.white;
    brushBottleMask.style = PaintingStyle.fill;
    brushWave.blendMode = BlendMode.srcIn;
    brushWave.style = PaintingStyle.fill;
    brushBubble.blendMode = BlendMode.srcATop;
    brushBubble.style = PaintingStyle.fill;
    brushGlossy.blendMode = BlendMode.srcATop;
    brushGlossy.style = PaintingStyle.fill;
    brushCap.blendMode = BlendMode.srcATop;
    brushCap.style = PaintingStyle.fill;
    brushCap.color = capColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    lastPaintTimestamp = DateTime.now();
    // repaintCount++;
    // print("repaint count "+repaintCount.toString());
    paintEmptyBottle(canvas, size);
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.saveLayer(rect, brushBottleMask);
    paintBottleMask(canvas, size);
    paintWaves(canvas, size);
    paintBubbles(canvas, size);
    brushGlossy.style = PaintingStyle.fill;
    paintGlossyOverlay(canvas, size);
    canvas.restore();
    paintCap(canvas, size);
  }

  void paintEmptyBottle(Canvas canvas, Size size) {
    final neckTop = size.width * 0.1;
    final neckBottom = size.height;
    final neckRingOuter = 0.0;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, brushBottle);
  }

  void paintBottleMask(Canvas canvas, Size size) {
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(
            neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5),
        brushBottleMask);
  }

  void paintWaves(Canvas canvas, Size size) {
    for (var wave in waves) {
      brushWave.color = wave.color;
      final transform = Matrix4.identity();
      final desiredW = 15 * size.width;
      final desiredH = 0.1 * size.height;
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.svgData.getBounds().width;
      final scaleY = desiredH / wave.svgData.getBounds().height;
      final translateX = -wave.offset * translateRange;
      final waterRange = size.height +
          desiredH; // 0 = no water = size.height; 1 = full water = -size.width
      final translateY = (1.0 - waterLevel) * waterRange - desiredH;
      transform.translate(translateX, translateY);
      transform.scale(scaleX, scaleY);
      canvas.drawPath(wave.svgData.transform(transform.storage), brushWave);
      if (waves.indexOf(wave) != waves.length - 1) {
        continue;
      }
      final gap = size.height - desiredH - translateY;
      if (gap > 0) {
        canvas.drawRect(
            Rect.fromLTRB(0, desiredH + translateY, size.width, size.height),
            brushWave);
      }
    }
  }

  void paintBubbles(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      brushBubble.color = bubble.color;
      final offset = Offset(
          bubble.x * size.width, (bubble.y + 1.0 - waterLevel) * size.height);
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, brushBubble);
    }
  }

  void paintGlossyOverlay(Canvas canvas, Size size) {
    brushGlossy.color = Colors.white.withAlpha(40);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width * 0.5, size.height), brushGlossy);
    brushGlossy.color = Colors.white.withAlpha(80);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.9, 0, size.width * 0.95, size.height),
        brushGlossy);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withAlpha(180),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    brushGlossy.color = Colors.white;
    brushGlossy.shader = gradient;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), brushGlossy);
  }

  void paintCap(Canvas canvas, Size size) {
    final capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.08 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.1 + 5;
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

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => false;
}

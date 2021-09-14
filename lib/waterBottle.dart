import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:waterbottle/bubble.dart';
import 'package:waterbottle/wave.dart';

class WaterBottle extends StatefulWidget {
  final Color color;
  WaterBottle({Key? key, this.color = Colors.blue}) : super(key: key);
  @override
  WaterBottleState createState() => WaterBottleState();
}

class WaterBottleState extends State<WaterBottle>
    with TickerProviderStateMixin {
  List<WaveLayer> waves = List<WaveLayer>.empty(growable: true);
  List<Bubble> bubbles = List<Bubble>.empty(growable: true);
  static const WAVE_COUNT = 3;
  static const BUBBLE_COUNT = 10;
  static const ONLY_LISTEN_TO_ONE_ANIMATION = false;

  @override
  void initState() {
    super.initState();
    var f = math.Random().nextInt(5000) + 15000;
    var d = math.Random().nextInt(500) + 1500;
    var color = HSLColor.fromColor(widget.color);
    for (var i = 0; i < WAVE_COUNT; i++) {
      final wave = WaveLayer();
      wave.init(this, frequency: f);
      final sat = color.saturation * math.pow(0.6, (WAVE_COUNT - 1 - i));
      final light = color.lightness * math.pow(0.8, (WAVE_COUNT - 1 - i));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
      waves.add(wave);
      f -= d;
      f = math.max(f, 0);
      if (!ONLY_LISTEN_TO_ONE_ANIMATION) {
        wave.animation.addListener(() {
          setState(() {});
        });
      }
    }
    if (ONLY_LISTEN_TO_ONE_ANIMATION && waves.length > 0) {
      waves.first.animation.addListener(() {
        setState(() {});
      });
    }

    for (var i = 0; i < BUBBLE_COUNT; i++) {
      final bubble = Bubble();
      bubble.init(this);
      bubble.randomize();
      bubbles.add(bubble);
    }
  }

  @override
  void dispose() {
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
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
            painter: WaterBottlePainter(waves: waves, bubbles: bubbles),
          ),
        ),
      ],
    );
  }
}

class WaterBottlePainter extends CustomPainter {
  final List<WaveLayer> waves;
  final List<Bubble> bubbles;

  WaterBottlePainter(
      {Listenable? repaint, required this.waves, required this.bubbles})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    {
      final paint = Paint();
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paintEmptyBottle(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      final rect = Rect.fromLTRB(0, 0, size.width, size.height);
      canvas.saveLayer(rect, paint);
      paintBottleMask(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcIn;
      paint.style = PaintingStyle.fill;
      paintWaves(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paintBubbles(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paintGlossyOverlay(canvas, size, paint);
    }
    canvas.restore();
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paint.color = Colors.blueGrey;
      paintCap(canvas, size, paint);
    }
  }

  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
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
    canvas.drawPath(path, paint);
  }

  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5), paint);
  }

  void paintWaves(Canvas canvas, Size size, Paint paint) {
    for (var wave in waves) {
      paint.color = wave.color;
      final transform = Matrix4.identity();
      final desiredW = 40 * size.width;
      final desiredH = math.min(size.width, size.height);
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.svgData.getBounds().width;
      final scaleY = desiredH / wave.svgData.getBounds().height;
      final translate = -wave.offset * translateRange;
      transform.translate(translate);
      transform.scale(scaleX, scaleY);
      canvas.drawPath(wave.svgData.transform(transform.storage), paint);
      if (waves.indexOf(wave) != waves.length - 1) {
        continue;
      }
      final gap = size.height - desiredH;
      if (gap > 0) {
        canvas.drawRect(
            Rect.fromLTRB(0, desiredH, size.width, size.height), paint);
      }
    }
  }

  void paintBubbles(Canvas canvas, Size size, Paint paint) {
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      final offset = Offset(bubble.x * size.width, bubble.y * size.height);
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withAlpha(20);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width * 0.5, size.height), paint);
    paint.color = Colors.white.withAlpha(80);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.9, 0, size.width * 0.95, size.height),
        paint);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withAlpha(180),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  void paintCap(Canvas canvas, Size size, Paint paint) {
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}

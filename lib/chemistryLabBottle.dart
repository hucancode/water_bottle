import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waterbottle/bubble.dart';
import 'package:waterbottle/waterBottle.dart';
import 'package:waterbottle/wave.dart';

// TODO: this aproach violates DRY principle, need to find a better inherritance design
class ChemistryLabBottle extends StatefulWidget {
  final Color color;
  ChemistryLabBottle({Key? key, this.color = Colors.blue}) : super(key: key);
  @override
  ChemistryLabBottleState createState() => ChemistryLabBottleState();
}

class ChemistryLabBottleState extends State<ChemistryLabBottle>
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
    super.dispose();
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
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
            painter: ChemistryLabBottlePainter(waves: waves, bubbles: bubbles),
          ),
        ),
      ],
    );
  }
}

class ChemistryLabBottlePainter extends WaterBottlePainter {
  ChemistryLabBottlePainter(
      {Listenable? repaint,
      required List<WaveLayer> waves,
      required List<Bubble> bubbles})
      : super(repaint: repaint, waves: waves, bubbles: bubbles);

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    canvas.drawCircle(Offset(r / 2, size.height - r / 2), r / 2, paint);
    canvas.drawRect(
        Rect.fromLTRB(
            size.width * 0.4, 0, size.width * 0.6, size.height - r / 2),
        paint);
    canvas.drawRect(
        Rect.fromLTRB(
            size.width * 0.35, 0, size.width * 0.65, size.width * 0.1),
        paint);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment.center, // near the top right
      colors: [
        Colors.white.withAlpha(120),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
    final r = math.min(size.width, size.height);
    // gradient
    canvas.drawRect(
        Rect.fromLTRB(0, size.height - r, size.width, size.height), paint);
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
}

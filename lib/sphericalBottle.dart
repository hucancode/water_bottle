import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waterbottle/bubble.dart';
import 'package:waterbottle/waterBottle.dart';
import 'package:waterbottle/waterContainer.dart';
import 'package:waterbottle/wave.dart';

class SphericalBottle extends StatefulWidget {
  final Color waterColor;
  final Color bottleColor;
  final Color capColor;
  SphericalBottle({Key? key, this.waterColor = Colors.blue, this.bottleColor = Colors.blue, this.capColor = Colors.blueGrey}) : super(key: key);
  @override
  SphericalBottleState createState() => SphericalBottleState();
}

class SphericalBottleState extends State<SphericalBottle>
    with TickerProviderStateMixin, WaterContainer  {

  @override
  void initState() {
    super.initState();
    initWater(widget.waterColor, this);
    waves.first.animation.addListener(() {
        setState(() {});
    });
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
              waves: waves, 
              bubbles: bubbles, 
              waterLevel: waterLevel,
              bottleColor: widget.bottleColor,
              capColor: widget.capColor,),
          ),
        ),
      ],
    );
  }
}

class SphericalBottlePainter extends WaterBottlePainter {
  static const BREAK_POINT = 1.2;
  SphericalBottlePainter(
      {Listenable? repaint,
      required List<WaveLayer> waves,
      required List<Bubble> bubbles,
      required double waterLevel,
      required Color bottleColor,
      required Color capColor,
      })
      : super(repaint: repaint, 
      waves: waves, 
      bubbles: bubbles, 
      waterLevel: waterLevel,
      bottleColor: bottleColor,
      capColor: capColor,);

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    if(size.height / size.width < BREAK_POINT)
    {
      canvas.drawCircle(Offset(size.width/2, size.height - r/2), r/2, paint);
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
    canvas.drawPath(path, paint);
    canvas.drawArc(Rect.fromLTRB(0, size.height - r, size.width, size.height),
        math.pi * 1.59, math.pi * 1.82, false, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    canvas.drawCircle(Offset(size.width/2, size.height - r / 2), r / 2 - 5, paint);
    if(size.height / size.width < BREAK_POINT)
    {
      return;
    }
    final neckTop = size.width * 0.1;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(neckRingInner + 5, neckTop, neckRingInnerR - 5,
            size.height - r / 2),
        paint);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final rect = Offset(0, size.height - r) & size;
    final gradient = RadialGradient(
      center: Alignment.center, // near the top right
      colors: [
        Colors.white.withAlpha(120),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
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
    if(size.height / size.width < BREAK_POINT) {
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
    canvas.drawPath(path, paint);
  }
}

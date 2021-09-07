import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterBottle extends StatefulWidget {
  WaterBottle({Key? key}) : super(key: key);
  @override
  WaterBottleState createState() => WaterBottleState();
}

class Bubble {
  late Animation<double> positionAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> sizeAnimation;
  late AnimationController controller;
  late TickerProvider provider;
  double initialX = 0;
  Color initialColor = Colors.blueGrey;
  
  Color get color => initialColor.withAlpha(opacityAnimation.value.toInt());
  double get x => initialX;
  double get y => positionAnimation.value;
  double get size => sizeAnimation.value;

  void init(TickerProvider provider) {
    this.provider = provider;
    // controller = AnimationController(
    //     vsync: provider,
    //     duration: Duration(milliseconds: 10000),
    // );
  }

  Curve randomCurve() {
    switch (math.Random().nextInt(5)) {
      case 0:
        return Curves.ease;
      case 1:
        return Curves.easeInOutSine;
      case 2:
        return Curves.easeInSine;
      case 3:
        return Curves.easeOutSine;
      case 4:
        return Curves.easeInOutQuad;
      case 5:
        return Curves.easeInQuad;
      case 6:
        return Curves.easeOutQuad;
      case 7:
        return Curves.easeInOutExpo;
      case 8:
        return Curves.easeOutExpo;
      case 9:
        return Curves.easeInExpo;
      default:
    }
    return Curves.linear;
  }

  void randomize() {
    controller = AnimationController(
        vsync: provider,
        duration: Duration(milliseconds: math.Random().nextInt(7000)+3000),
    );
    initialColor = HSLColor.fromAHSL(
      1.0, 
      math.Random().nextDouble(), 
      math.Random().nextDouble()*0.3, 
      math.Random().nextDouble()*0.3+0.7).toColor();
    initialX = math.Random().nextDouble();
    double initialY = math.Random().nextDouble()*0.3+1.0;
    double finalY = math.Random().nextDouble()*0.3+0.2;
    double initialSize = math.Random().nextDouble()*10;
    double finalSize = math.Random().nextDouble()*20;

    positionAnimation = Tween<double>(begin: initialY, end: finalY).animate(
      CurvedAnimation(parent: controller, curve: randomCurve())
    );
    sizeAnimation = Tween<double>(begin: initialSize, end: finalSize).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutSine)
    );
    opacityAnimation = Tween<double>(begin: math.Random().nextDouble()*100+155, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutSine)
    );
    positionAnimation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
          randomize();
        }
    });
    controller.forward();
  }
}

class WaveLayer {
  late final Animation<double> animation;
  late final AnimationController controller;
  final svgData = Path();
  Color color = Colors.blueGrey;

  double get offset => animation.value;

  void init(TickerProvider provider, {int frequency = 10, int preset = 0})
  {
    controller = AnimationController(
        vsync: provider,
        duration: Duration(milliseconds: frequency),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutSine)
    );
    animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat(reverse: true);
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
    });
    controller.forward();
    buildPath(preset: preset);
  }
  void buildPath({int preset = 0})
  {
    switch (preset) {
      case 0:
        svgData.moveTo(0,96);
        svgData.lineTo(24,128);
        svgData.cubicTo(48,160,96,224,144,229.3);
        svgData.cubicTo(192,235,240,181,288,138.7);
        svgData.cubicTo(336,96,384,64,432,48);
        svgData.cubicTo(480,32,528,32,576,53.3);
        svgData.cubicTo(624,75,672,117,720,144);
        svgData.cubicTo(768,171,816,181,864,160);
        svgData.cubicTo(912,139,960,85,1008,101.3);
        svgData.cubicTo(1056,117,1104,203,1152,213.3);
        svgData.cubicTo(1200,224,1248,160,1296,154.7);
        svgData.cubicTo(1344,149,1392,203,1416,229.3);
        svgData.lineTo(1440,256);
        svgData.lineTo(1440,320);
        svgData.lineTo(1416,320);
        svgData.cubicTo(1392,320,1344,320,1296,320);
        svgData.cubicTo(1248,320,1200,320,1152,320);
        svgData.cubicTo(1104,320,1056,320,1008,320);
        svgData.cubicTo(960,320,912,320,864,320);
        svgData.cubicTo(816,320,768,320,720,320);
        svgData.cubicTo(672,320,624,320,576,320);
        svgData.cubicTo(528,320,480,320,432,320);
        svgData.cubicTo(384,320,336,320,288,320);
        svgData.cubicTo(240,320,192,320,144,320);
        svgData.cubicTo(96,320,48,320,24,320);
        svgData.lineTo(0,320);
        svgData.close();
        break;
      case 1:
        svgData.moveTo(0,160);
        svgData.lineTo(24,138.7);
        svgData.cubicTo(48,117,96,75,144,69.3);
        svgData.cubicTo(192,64,240,96,288,138.7);
        svgData.cubicTo(336,181,384,235,432,256);
        svgData.cubicTo(480,277,528,267,576,250.7);
        svgData.cubicTo(624,235,672,213,720,208);
        svgData.cubicTo(768,203,816,213,864,197.3);
        svgData.cubicTo(912,181,960,139,1008,154.7);
        svgData.cubicTo(1056,171,1104,245,1152,240);
        svgData.cubicTo(1200,235,1248,149,1296,128);
        svgData.cubicTo(1344,107,1392,149,1416,170.7);
        svgData.lineTo(1440,192);
        svgData.lineTo(1440,320);
        svgData.lineTo(1416,320);
        svgData.cubicTo(1392,320,1344,320,1296,320);
        svgData.cubicTo(1248,320,1200,320,1152,320);
        svgData.cubicTo(1104,320,1056,320,1008,320);
        svgData.cubicTo(960,320,912,320,864,320);
        svgData.cubicTo(816,320,768,320,720,320);
        svgData.cubicTo(672,320,624,320,576,320);
        svgData.cubicTo(528,320,480,320,432,320);
        svgData.cubicTo(384,320,336,320,288,320);
        svgData.cubicTo(240,320,192,320,144,320);
        svgData.cubicTo(96,320,48,320,24,320);
        svgData.lineTo(0,320);
        svgData.close();
        break;
      case 2:
        svgData.moveTo(0,128);
        svgData.lineTo(24,128);
        svgData.cubicTo(48,128,96,128,144,144);
        svgData.cubicTo(192,160,240,192,288,213.3);
        svgData.cubicTo(336,235,384,245,432,224);
        svgData.cubicTo(480,203,528,149,576,128);
        svgData.cubicTo(624,107,672,117,720,122.7);
        svgData.cubicTo(768,128,816,128,864,133.3);
        svgData.cubicTo(912,139,960,149,1008,144);
        svgData.cubicTo(1056,139,1104,117,1152,112);
        svgData.cubicTo(1200,107,1248,117,1296,112);
        svgData.cubicTo(1344,107,1392,85,1416,74.7);
        svgData.lineTo(1440,64);
        svgData.lineTo(1440,320);
        svgData.lineTo(1416,320);
        svgData.cubicTo(1392,320,1344,320,1296,320);
        svgData.cubicTo(1248,320,1200,320,1152,320);
        svgData.cubicTo(1104,320,1056,320,1008,320);
        svgData.cubicTo(960,320,912,320,864,320);
        svgData.cubicTo(816,320,768,320,720,320);
        svgData.cubicTo(672,320,624,320,576,320);
        svgData.cubicTo(528,320,480,320,432,320);
        svgData.cubicTo(384,320,336,320,288,320);
        svgData.cubicTo(240,320,192,320,144,320);
        svgData.cubicTo(96,320,48,320,24,320);
        svgData.lineTo(0,320);
        svgData.close();
        break;
      default:
    }
  }
}

class WaterBottleState extends State<WaterBottle>
    with TickerProviderStateMixin {
  List<WaveLayer> waves = List<WaveLayer>.empty(growable: true);
  List<Bubble> bubbles = List<Bubble>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    {
      final wave = WaveLayer();
      wave.init(this, frequency: 11800, preset: 0);
      wave.color = Colors.blueGrey;
      waves.add(wave);
    }
    {
      final wave = WaveLayer();
      wave.init(this, frequency: 9620, preset: 1);
      wave.color = Colors.blue;
      waves.add(wave);
    }
    {
      final wave = WaveLayer();
      wave.init(this, frequency: 4230, preset: 2);
      wave.color = Colors.lightBlue;
      waves.add(wave);
      wave.animation.addListener(() {
        setState(() {});
      });
    }

    for (var i = 0; i < 30; i++) {
      final bubble = Bubble();
      bubble.init(this);
      bubble.randomize();
      bubbles.add(bubble);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1/1,
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

  WaterBottlePainter({ 
    Listenable? repaint, 
    required this.waves, 
    required this.bubbles}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    
    for (var wave in waves) {
      final paint = Paint();
      paint.color = wave.color;
      paint.style = PaintingStyle.fill;
      final transform = Matrix4.identity();
      final desiredW = 10 * size.width;
      final desiredH = math.min(size.width, size.height);
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.svgData.getBounds().width;
      final scaleY = desiredH / wave.svgData.getBounds().height;
      final translate = -wave.offset * translateRange;
      transform.translate(translate);
      transform.scale(scaleX, scaleY);
      canvas.drawPath(wave.svgData.transform(transform.storage), paint);
      if(waves.indexOf(wave) != waves.length - 1)
      {
        continue;
      }
      final gap = size.height - desiredH;
      if(gap > 0)
      {
        canvas.drawRect(Rect.fromLTRB(0, desiredH, size.width, size.height), paint);
      }
    }
    for (var bubble in bubbles) {
      final paint = Paint();
      paint.color = bubble.color;
      paint.style = PaintingStyle.fill;
      final offset = Offset(bubble.x * size.width, bubble.y * size.height);
      canvas.drawCircle(offset, bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:path_parsing/path_parsing.dart';

class WaterBottle extends StatefulWidget {
  final Color color;
  WaterBottle({Key? key, this.color = Colors.blue}) : super(key: key);
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
    double initialSize = math.Random().nextDouble()*0.01;
    double finalSize = math.Random().nextDouble()*0.1;

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

class PathWriter extends PathProxy {
  PathWriter({Path? path}) : this.path = path ?? Path();

  final Path path;

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}

class WaveLayer {
  late final Animation<double> animation;
  late final AnimationController controller;
  final svgData = Path();
  Color color = Colors.blueGrey;

  double get offset => animation.value;

  void init(TickerProvider provider, {int frequency = 10})
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
    buildPath();
  }
  void buildPath()
  {
    // for beautiful waves, see https://getwaves.io/
    const PATH_DATAS = [
      "M0,160L6.2,160C12.3,160,25,160,37,165.3C49.2,171,62,181,74,170.7C86.2,160,98,128,111,138.7C123.1,149,135,203,148,218.7C160,235,172,213,185,208C196.9,203,209,213,222,181.3C233.8,149,246,75,258,64C270.8,53,283,107,295,138.7C307.7,171,320,181,332,202.7C344.6,224,357,256,369,261.3C381.5,267,394,245,406,197.3C418.5,149,431,75,443,58.7C455.4,43,468,85,480,90.7C492.3,96,505,64,517,96C529.2,128,542,224,554,245.3C566.2,267,578,213,591,186.7C603.1,160,615,160,628,181.3C640,203,652,245,665,256C676.9,267,689,245,702,224C713.8,203,726,181,738,149.3C750.8,117,763,75,775,74.7C787.7,75,800,117,812,144C824.6,171,837,181,849,170.7C861.5,160,874,128,886,101.3C898.5,75,911,53,923,58.7C935.4,64,948,96,960,106.7C972.3,117,985,107,997,96C1009.2,85,1022,75,1034,112C1046.2,149,1058,235,1071,256C1083.1,277,1095,235,1108,213.3C1120,192,1132,192,1145,165.3C1156.9,139,1169,85,1182,69.3C1193.8,53,1206,75,1218,80C1230.8,85,1243,75,1255,74.7C1267.7,75,1280,85,1292,122.7C1304.6,160,1317,224,1329,245.3C1341.5,267,1354,245,1366,240C1378.5,235,1391,245,1403,229.3C1415.4,213,1428,171,1434,149.3L1440,128L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,288L6.2,282.7C12.3,277,25,267,37,250.7C49.2,235,62,213,74,176C86.2,139,98,85,111,74.7C123.1,64,135,96,148,101.3C160,107,172,85,185,85.3C196.9,85,209,107,222,149.3C233.8,192,246,256,258,250.7C270.8,245,283,171,295,170.7C307.7,171,320,245,332,261.3C344.6,277,357,235,369,224C381.5,213,394,235,406,240C418.5,245,431,235,443,202.7C455.4,171,468,117,480,85.3C492.3,53,505,43,517,85.3C529.2,128,542,224,554,240C566.2,256,578,192,591,160C603.1,128,615,128,628,128C640,128,652,128,665,117.3C676.9,107,689,85,702,106.7C713.8,128,726,192,738,208C750.8,224,763,192,775,186.7C787.7,181,800,203,812,213.3C824.6,224,837,224,849,234.7C861.5,245,874,267,886,277.3C898.5,288,911,288,923,277.3C935.4,267,948,245,960,229.3C972.3,213,985,203,997,218.7C1009.2,235,1022,277,1034,282.7C1046.2,288,1058,256,1071,250.7C1083.1,245,1095,267,1108,245.3C1120,224,1132,160,1145,149.3C1156.9,139,1169,181,1182,170.7C1193.8,160,1206,96,1218,74.7C1230.8,53,1243,75,1255,112C1267.7,149,1280,203,1292,234.7C1304.6,267,1317,277,1329,277.3C1341.5,277,1354,267,1366,245.3C1378.5,224,1391,192,1403,186.7C1415.4,181,1428,203,1434,213.3L1440,224L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,32L6.2,48C12.3,64,25,96,37,138.7C49.2,181,62,235,74,218.7C86.2,203,98,117,111,80C123.1,43,135,53,148,85.3C160,117,172,171,185,165.3C196.9,160,209,96,222,85.3C233.8,75,246,117,258,154.7C270.8,192,283,224,295,240C307.7,256,320,256,332,218.7C344.6,181,357,107,369,85.3C381.5,64,394,96,406,101.3C418.5,107,431,85,443,117.3C455.4,149,468,235,480,229.3C492.3,224,505,128,517,117.3C529.2,107,542,181,554,213.3C566.2,245,578,235,591,208C603.1,181,615,139,628,138.7C640,139,652,181,665,192C676.9,203,689,181,702,149.3C713.8,117,726,75,738,80C750.8,85,763,139,775,138.7C787.7,139,800,85,812,64C824.6,43,837,53,849,64C861.5,75,874,85,886,80C898.5,75,911,53,923,64C935.4,75,948,117,960,133.3C972.3,149,985,139,997,138.7C1009.2,139,1022,149,1034,160C1046.2,171,1058,181,1071,170.7C1083.1,160,1095,128,1108,133.3C1120,139,1132,181,1145,186.7C1156.9,192,1169,160,1182,149.3C1193.8,139,1206,149,1218,181.3C1230.8,213,1243,267,1255,250.7C1267.7,235,1280,149,1292,112C1304.6,75,1317,85,1329,106.7C1341.5,128,1354,160,1366,160C1378.5,160,1391,128,1403,122.7C1415.4,117,1428,139,1434,149.3L1440,160L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,32L6.2,48C12.3,64,25,96,37,106.7C49.2,117,62,107,74,96C86.2,85,98,75,111,69.3C123.1,64,135,64,148,74.7C160,85,172,107,185,96C196.9,85,209,43,222,58.7C233.8,75,246,149,258,165.3C270.8,181,283,139,295,122.7C307.7,107,320,117,332,122.7C344.6,128,357,128,369,160C381.5,192,394,256,406,261.3C418.5,267,431,213,443,165.3C455.4,117,468,75,480,64C492.3,53,505,75,517,106.7C529.2,139,542,181,554,176C566.2,171,578,117,591,117.3C603.1,117,615,171,628,186.7C640,203,652,181,665,186.7C676.9,192,689,224,702,250.7C713.8,277,726,299,738,293.3C750.8,288,763,256,775,256C787.7,256,800,288,812,256C824.6,224,837,128,849,101.3C861.5,75,874,117,886,122.7C898.5,128,911,96,923,101.3C935.4,107,948,149,960,181.3C972.3,213,985,235,997,234.7C1009.2,235,1022,213,1034,224C1046.2,235,1058,277,1071,288C1083.1,299,1095,277,1108,224C1120,171,1132,85,1145,74.7C1156.9,64,1169,128,1182,133.3C1193.8,139,1206,85,1218,69.3C1230.8,53,1243,75,1255,122.7C1267.7,171,1280,245,1292,282.7C1304.6,320,1317,320,1329,309.3C1341.5,299,1354,277,1366,266.7C1378.5,256,1391,256,1403,245.3C1415.4,235,1428,213,1434,202.7L1440,192L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z"
    ];
    final i = math.Random().nextInt(PATH_DATAS.length);
    writeSvgPathDataToPath(PATH_DATAS[i], PathWriter(path: svgData));
  }
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
    var f = math.Random().nextInt(5000) + 25000;
    var d = math.Random().nextInt(3000) + 2000;
    var color = HSLColor.fromColor(widget.color);
    for (var i = 0; i < WAVE_COUNT; i++)
    {
      final wave = WaveLayer();
      wave.init(this, frequency: f);
      final sat = color.saturation * math.pow(0.6, (WAVE_COUNT - 1 - i));
      final light = color.lightness * math.pow(0.8, (WAVE_COUNT - 1 - i));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
      waves.add(wave);
      f -= d;
      f = math.max(f, 0);
      if(!ONLY_LISTEN_TO_ONE_ANIMATION)
      {
          wave.animation.addListener(() {
            setState(() {});
          });
      }
    }
    if(ONLY_LISTEN_TO_ONE_ANIMATION && waves.length > 0)
    {
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
      final desiredW = 30 * size.width;
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
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}

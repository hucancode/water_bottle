import 'package:flutter/material.dart';
import 'package:water_bottle/water_bottle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Bottle Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Water Bottle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final plainBottleRef = GlobalKey<WaterBottleState>();
  final sphereBottleRef = GlobalKey<SphericalBottleState>();
  final triangleBottleRef = GlobalKey<TriangularBottleState>();
  var waterLevel = 0.5;
  var selectedStyle = 0;
  @override
  Widget build(BuildContext context) {
    final plain = WaterBottle(
        key: plainBottleRef,
        waterColor: Colors.blue,
        bottleColor: Colors.lightBlue,
        capColor: Colors.blueGrey);
    final sphere = SphericalBottle(
      key: sphereBottleRef,
      waterColor: Colors.red,
      bottleColor: Colors.redAccent,
      capColor: Colors.grey.shade700,
    );
    final triangle = TriangularBottle(
      key: triangleBottleRef,
      waterColor: Colors.lime,
      bottleColor: Colors.limeAccent,
      capColor: Colors.red,
    );
    final bottle = Center(
      child: SizedBox(
        width: 200,
        height: 300,
        child: selectedStyle == 0
            ? plain
            : selectedStyle == 1
                ? sphere
                : triangle,
      ),
    );
    final stylePicker = Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
      child: Center(
        child: ToggleButtons(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: Icon(Icons.crop_portrait),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: Icon(Icons.circle_outlined),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: Icon(Icons.change_history),
            ),
          ],
          isSelected: List<bool>.generate(3, (index) => index == selectedStyle),
          onPressed: (index) => setState(() => selectedStyle = index),
        ),
      ),
    );
    final waterSlider = Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.opacity),
          SizedBox(width: 10),
          Expanded(
            child: Slider(
              value: waterLevel,
              max: 1.0,
              min: 0.0,
              onChanged: (value) {
                setState(
                  () {
                    waterLevel = value;
                    plainBottleRef.currentState?.waterLevel = waterLevel;
                    sphereBottleRef.currentState?.waterLevel = waterLevel;
                    triangleBottleRef.currentState?.waterLevel = waterLevel;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            bottle,
            Spacer(),
            stylePicker,
            waterSlider,
            Spacer(),
          ],
        ),
      ),
    );
  }
}

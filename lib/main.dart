import 'package:flutter/material.dart';
import 'package:waterbottle/waterBottle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity, 
        height: double.infinity,
        color: Colors.white10,
        child: Center(
          child: SizedBox(
            width: 100, 
            height: 200, 
            child: ClipRect(child: WaterBottle(color: Colors.purpleAccent)),
          ),
        ),
      ),
    );
  }
}

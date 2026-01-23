import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle_example/main.dart';
import 'package:water_bottle/water_bottle.dart';

void main() {
  group('Example App Tests', () {
    testWidgets('App launches and displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Water Bottle'), findsOneWidget);
      expect(find.byType(WaterBottle), findsOneWidget);
      expect(find.byType(ToggleButtons), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Toggle buttons switch bottle styles', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(WaterBottle), findsOneWidget);

      await tester.tap(find.byIcon(Icons.circle_outlined));
      await tester.pump();

      expect(find.byType(SphericalBottle), findsOneWidget);
      expect(find.byType(WaterBottle), findsNothing);

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pump();

      expect(find.byType(TriangularBottle), findsOneWidget);
      expect(find.byType(SphericalBottle), findsNothing);

      await tester.tap(find.byIcon(Icons.crop_portrait));
      await tester.pump();

      expect(find.byType(WaterBottle), findsOneWidget);
      expect(find.byType(TriangularBottle), findsNothing);
    });

    testWidgets('Slider updates water level', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      Slider slider = tester.widget(sliderFinder);
      expect(slider.value, 0.5);

      await tester.drag(sliderFinder, const Offset(100, 0));
      await tester.pump();

      slider = tester.widget(sliderFinder);
      expect(slider.value, greaterThan(0.5));
    });

    testWidgets('Bottle colors are correctly set', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      WaterBottle plainBottle = tester.widget(find.byType(WaterBottle));
      expect(plainBottle.waterColor, Colors.blue);
      expect(plainBottle.bottleColor, Colors.lightBlue);
      expect(plainBottle.capColor, Colors.blueGrey);

      await tester.tap(find.byIcon(Icons.circle_outlined));
      await tester.pump();

      SphericalBottle sphereBottle = tester.widget(find.byType(SphericalBottle));
      expect(sphereBottle.waterColor, Colors.red);
      expect(sphereBottle.bottleColor, Colors.redAccent);

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pump();

      TriangularBottle triangleBottle = tester.widget(find.byType(TriangularBottle));
      expect(triangleBottle.waterColor, Colors.lime);
      expect(triangleBottle.bottleColor, Colors.limeAccent);
    });
  });
}

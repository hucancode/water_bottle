import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_bottle/water_bottle.dart';

void main() {
  group('WaterBottle Widget Tests', () {
    testWidgets('WaterBottle water level can be updated', (WidgetTester tester) async {
      final key = GlobalKey<WaterBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: WaterBottle(key: key),
            ),
          ),
        ),
      );

      // Initial water level should be 0.5 (default)
      expect(key.currentState?.waterLevel, 0.5);

      // Update water level
      key.currentState?.waterLevel = 0.8;
      await tester.pump();

      expect(key.currentState?.waterLevel, 0.8);

      // Update to minimum
      key.currentState?.waterLevel = 0.0;
      await tester.pump();

      expect(key.currentState?.waterLevel, 0.0);

      // Update to maximum
      key.currentState?.waterLevel = 1.0;
      await tester.pump();

      expect(key.currentState?.waterLevel, 1.0);
    });
    testWidgets('SphericalBottle water level can be updated', (WidgetTester tester) async {
      final key = GlobalKey<SphericalBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: SphericalBottle(key: key),
            ),
          ),
        ),
      );

      // Initial water level should be 0.5 (default)
      expect(key.currentState?.waterLevel, 0.5);

      // Update water level
      key.currentState?.waterLevel = 0.75;
      await tester.pump();

      expect(key.currentState?.waterLevel, 0.75);
    });
    testWidgets('TriangularBottle water level can be updated', (WidgetTester tester) async {
      final key = GlobalKey<TriangularBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: TriangularBottle(key: key),
            ),
          ),
        ),
      );

      // Initial water level should be 0.5 (default)
      expect(key.currentState?.waterLevel, 0.5);

      // Update water level
      key.currentState?.waterLevel = 0.25;
      await tester.pump();

      expect(key.currentState?.waterLevel, 0.25);
    });
    testWidgets('WaterContainer initializes waves and bubbles', (WidgetTester tester) async {
      final key = GlobalKey<WaterBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: WaterBottle(key: key),
            ),
          ),
        ),
      );

      // Check that waves are initialized
      expect(key.currentState?.waves.length, 3); // WAVE_COUNT = 3

      // Check that bubbles are initialized
      expect(key.currentState?.bubbles.length, 10); // BUBBLE_COUNT = 10

      // Verify waves are properly initialized
      for (var wave in key.currentState!.waves) {
        expect(wave.controller, isNotNull);
        expect(wave.animation, isNotNull);
      }

      // Verify bubbles are properly initialized
      for (var bubble in key.currentState!.bubbles) {
        expect(bubble.controller, isNotNull);
        expect(bubble.positionAnimation, isNotNull);
      }
    });
  });

  group('Animation Tests', () {
    testWidgets('WaterBottle animations run properly', (WidgetTester tester) async {
      final key = GlobalKey<WaterBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: WaterBottle(key: key),
            ),
          ),
        ),
      );

      // Let animations run for a bit
      await tester.pump(const Duration(milliseconds: 100));

      // Verify wave animations are active
      for (var wave in key.currentState!.waves) {
        expect(wave.controller.isAnimating || wave.controller.isCompleted, true);
      }
    });

  });

  group('Edge Cases', () {
    testWidgets('WaterBottle handles extreme water levels', (WidgetTester tester) async {
      final key = GlobalKey<WaterBottleState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: WaterBottle(key: key),
            ),
          ),
        ),
      );

      // Test negative value (below 0)
      key.currentState?.waterLevel = -0.5;
      await tester.pump();
      expect(key.currentState?.waterLevel, -0.5);

      // Test value above 1
      key.currentState?.waterLevel = 1.5;
      await tester.pump();
      expect(key.currentState?.waterLevel, 1.5);

      // Should still render without errors
      expect(find.byType(WaterBottle), findsOneWidget);
    });
  });
}

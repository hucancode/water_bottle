import 'dart:math' as math;
import 'package:flutter/material.dart';

class Bubble {
  /// Bubble animations
  late Animation<double> positionAnimation;

  /// Bubble animations
  late Animation<double> opacityAnimation;

  /// Bubble animations
  late Animation<double> sizeAnimation;

  /// Bubble animation controller
  late AnimationController controller;
  late TickerProvider provider;

  /// X position
  double initialX = 0;

  /// Starting color
  Color initialColor = Colors.blueGrey;

  /// Current color
  Color get color => initialColor.withAlpha(opacityAnimation.value.toInt());

  /// Current X position
  double get x => initialX;

  /// Current Y position
  double get y => positionAnimation.value;

  /// Current size
  double get size => sizeAnimation.value;

  /// Setup animations
  void init(TickerProvider provider) {
    this.provider = provider;
    controller = AnimationController(
      vsync: provider,
      duration: Duration(milliseconds: 10000),
    );
  }

  /// Clean up
  void dispose() {
    controller.dispose();
  }

  /// Get a random easing method
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

  /// Randomize bubble behavior, run at initialization or respawn
  void randomize() {
    controller.duration =
        Duration(milliseconds: math.Random().nextInt(7000) + 3000);
    initialColor = HSLColor.fromAHSL(
            1.0,
            math.Random().nextDouble(),
            math.Random().nextDouble() * 0.3,
            math.Random().nextDouble() * 0.3 + 0.7)
        .toColor();
    initialX = math.Random().nextDouble();
    double initialY = math.Random().nextDouble() * 0.3 + 1.0;
    double finalY = math.Random().nextDouble() * 0.3 + 0.2;
    double initialSize = math.Random().nextDouble() * 0.01;
    double finalSize = math.Random().nextDouble() * 0.1;

    positionAnimation = Tween<double>(begin: initialY, end: finalY)
        .animate(CurvedAnimation(parent: controller, curve: randomCurve()));
    sizeAnimation = Tween<double>(begin: initialSize, end: finalSize).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine));
    opacityAnimation = Tween<double>(
            begin: math.Random().nextDouble() * 100 + 155, end: 0)
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOutSine));
    positionAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat();
        randomize();
      }
    });
    controller.forward();
  }
}

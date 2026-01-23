import 'dart:math' as math;
import 'package:flutter/material.dart';

class Bubble {
  /// Shared random instance for better performance
  static final _random = math.Random();

  /// Bubble animations
  late Animation<double> positionAnimation;

  /// Bubble animations
  late Animation<double> opacityAnimation;

  /// Bubble animations
  late Animation<double> sizeAnimation;

  CurvedAnimation? _positionCurved;
  CurvedAnimation? _opacityCurved;
  CurvedAnimation? _sizeCurved;

  late Tween<double> _positionTween;
  late Tween<double> _sizeTween;
  late Tween<double> _opacityTween;

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

  /// Animation status listener to avoid memory leaks
  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      controller.repeat();
      randomize();
    }
  }

  /// Setup animations
  void init(TickerProvider provider) {
    this.provider = provider;
    controller = AnimationController(
      vsync: provider,
      duration: Duration(milliseconds: 10000),
    );
    _positionTween = Tween<double>(begin: 0.0, end: 0.0);
    _sizeTween = Tween<double>(begin: 0.0, end: 0.0);
    _opacityTween = Tween<double>(begin: 0.0, end: 0.0);
  }

  /// Clean up
  void dispose() {
    _positionCurved?.dispose();
    _opacityCurved?.dispose();
    _sizeCurved?.dispose();
    controller.dispose();
  }

  /// Get a random easing method
  Curve randomCurve() {
    switch (_random.nextInt(5)) {
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
      default:
        return Curves.linear;
    }
  }

  /// Randomize bubble behavior, run at initialization or respawn
  void randomize() {
    controller.duration =
        Duration(milliseconds: _random.nextInt(7000) + 3000);
    initialColor = HSLColor.fromAHSL(
            1.0,
            _random.nextDouble(),
            _random.nextDouble() * 0.3,
            _random.nextDouble() * 0.3 + 0.7)
        .toColor();
    initialX = _random.nextDouble();
    double initialY = _random.nextDouble() * 0.3 + 1.0;
    double finalY = _random.nextDouble() * 0.3 + 0.2;
    double initialSize = _random.nextDouble() * 0.01;
    double finalSize = _random.nextDouble() * 0.1;

    // Reuse Tween objects by updating their begin/end values
    _positionTween.begin = initialY;
    _positionTween.end = finalY;
    _sizeTween.begin = initialSize;
    _sizeTween.end = finalSize;
    _opacityTween.begin = _random.nextDouble() * 100 + 155;
    _opacityTween.end = 0;

    _positionCurved?.dispose();
    _opacityCurved?.dispose();
    _sizeCurved?.dispose();

    _positionCurved = CurvedAnimation(parent: controller, curve: randomCurve());
    _sizeCurved = CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);
    _opacityCurved = CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);

    positionAnimation = _positionTween.animate(_positionCurved!);
    sizeAnimation = _sizeTween.animate(_sizeCurved!);
    opacityAnimation = _opacityTween.animate(_opacityCurved!);

    positionAnimation.removeStatusListener(_onAnimationComplete);
    positionAnimation.addStatusListener(_onAnimationComplete);
    controller.forward();
  }
}

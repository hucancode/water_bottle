import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bubble.dart';
import 'wave.dart';

mixin class WaterContainer {
  /// Shared random instance for better performance
  static final _random = math.Random();

  /// Holds all wave object instances
  List<WaveLayer> waves = [];

  /// Holds all bubble object instances
  List<Bubble> bubbles = [];

  /// How many wave layer do we need, default 3
  static const WAVE_COUNT = 3;

  /// How many bubbles can exist at the same time? The more the expensive, default 10
  static const BUBBLE_COUNT = 10;

  /// You can set water level with [waterLevel]. 0 = no water, 1 = full water
  double waterLevel = 0.5;

  /// Instantiate wave and bubble objects
  void initWater(Color themeColor, TickerProvider ticker) {
    // Pre-allocate lists with known size
    waves = List<WaveLayer>.generate(WAVE_COUNT, (_) => WaveLayer(), growable: false);
    bubbles = List<Bubble>.generate(BUBBLE_COUNT, (_) => Bubble(), growable: false);

    var f = _random.nextInt(5000) + 15000;
    var d = _random.nextInt(500) + 1500;
    var color = HSLColor.fromColor(themeColor);
    for (var i = 0; i < WAVE_COUNT; i++) {
      final wave = waves[i];
      wave.init(ticker, frequency: f);
      final sat = color.saturation * math.pow(0.6, (WAVE_COUNT - i - 1));
      final light = color.lightness * math.pow(0.8, (WAVE_COUNT - i - 1));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
      f -= d;
      f = math.max(f, 0);
    }

    for (var i = 0; i < BUBBLE_COUNT; i++) {
      final bubble = bubbles[i];
      bubble.init(ticker);
      bubble.randomize();
    }
  }

  /// Kill wave and bubble objects
  void disposeWater() {
    for (var wave in waves) {
      wave.dispose();
    }
    for (var bubble in bubbles) {
      bubble.dispose();
    }
  }
}

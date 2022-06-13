import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bubble.dart';
import 'wave.dart';

class WaterContainer {
  List<WaveLayer> waves = List<WaveLayer>.empty(growable: true);
  List<Bubble> bubbles = List<Bubble>.empty(growable: true);
  static const WAVE_COUNT = 3;
  static const BUBBLE_COUNT = 10;
  // You can set water level with [waterLevel]. 0 = no water, 1 = full water
  double waterLevel = 0.5;

  void initWater(Color themeColor, TickerProvider ticker) {
    var f = math.Random().nextInt(5000) + 15000;
    var d = math.Random().nextInt(500) + 1500;
    var color = HSLColor.fromColor(themeColor);
    for (var i = 1; i <= WAVE_COUNT; i++) {
      final wave = WaveLayer();
      wave.init(ticker, frequency: f);
      final sat = color.saturation * math.pow(0.6, (WAVE_COUNT - i));
      final light = color.lightness * math.pow(0.8, (WAVE_COUNT - i));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
      waves.add(wave);
      f -= d;
      f = math.max(f, 0);
    }

    for (var i = 0; i < BUBBLE_COUNT; i++) {
      final bubble = Bubble();
      bubble.init(ticker);
      bubble.randomize();
      bubbles.add(bubble);
    }
  }

  void disposeWater() {
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
  }
}

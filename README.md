# Water Bottle

## Features

This library add a bottle widget to your screen. You can use it as a loading indicator, a progress tracker, or any kind of measurement suits your needs.

![Plain](https://github.com/hucancode/water_bottle/blob/main/readme/cup.gif?raw=true)
![Sphere](https://github.com/hucancode/water_bottle/blob/main/readme/sphere.gif?raw=true)
![Triangle](https://github.com/hucancode/water_bottle/blob/main/readme/triangle.gif?raw=true)

Sphere bottle get reduced to a ball when aspect ratio smaller than 1

![Responsive Sphere](https://github.com/hucancode/water_bottle/blob/main/readme/sphere_responsive.gif?raw=true)

## Usage

To use this library, add `water_bottle` as a [dependency in your pubspec.yaml](https://flutter.dev/docs/development/platform-integration/platform-channels) file.

Import it where you need
```dart
import 'package:water_bottle/water_bottle.dart';
```
Build bottle widget
```dart
final plainBottleRef = GlobalKey<WaterBottleState>();
WaterBottle(
    key: plainBottleRef, 
    waterColor: Colors.blue, 
    bottleColor: Colors.lightBlue,
    capColor: Colors.blueGrey
)
```
Update widget
```dart
plainBottleRef.currentState?.waterLevel = 0.5;// 0.0~1.0
```
For more please refer `/example` folder

## Additional information

For more information, or contribution, please refer to the original [github](https://github.com/hucancode/water_bottle)
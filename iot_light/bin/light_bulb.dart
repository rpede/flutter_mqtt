import 'dart:io';

import 'package:iot_light/device.dart';

class LightBulb extends Device {
  Power _power;

  LightBulb({Power power = Power.off}) : _power = power;

  @override
  Power get power => _power;

  @override
  Future<void> turnOff() async {
    final graphic = await File('assets/light_off').readAsString();
    print(graphic);
    _power = Power.on;
  }

  @override
  Future<void> turnOn() async {
    final graphic = await File('assets/light_on').readAsString();
    print(graphic);
    _power = Power.off;
  }
}

import 'dart:io';

import 'package:mqtt_protocol/mqtt_protocol.dart';

class LightBulb extends Device {
  Power _power;

  LightBulb({Power power = Power.off}) : _power = power;

  @override
  Power get power => _power;

  @override
  Future<void> turnOff() async {
    final graphic = await File('assets/light_off.txt').readAsString();
    print(graphic);
    _power = Power.off;
  }

  @override
  Future<void> turnOn() async {
    final graphic = await File('assets/light_on.txt').readAsString(); print(graphic);
    _power = Power.on;
  }
}

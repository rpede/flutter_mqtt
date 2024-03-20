enum Power { on, off }

abstract class Device {
  Power get power;
  Future<void> turnOff();
  Future<void> turnOn();
}

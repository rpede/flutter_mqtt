# MQTT Example

Here is an example of how to use MQTT (v3) with dart/flutter.

There are 4 projects:

- **smart_light_dart** Simulates a IoT "smart" light that can be turned on and off.
- **smart_light_esp32** IoT "smart" light sketch for ESP32 boards.
- **light_controller** is a flutter app using BLoC that can control the light.
- **light_protocol** Dart implementation of the protocol for both controller and device.

I have tested it on Mosquitto as MQTT broker and FireBeetle ESP32-E board.

![Flow of messages](./mqtt-light.drawio.svg)

## Server address

Check server address in `main.dart` files and `smart_light.ino`.

- Set to `10.0.2.2` when running in Android Emulator

## Getting started

**Broker**

```sh
mosquitto -c mosquitto.conf
```

**Smart light ESP32**

[Instructions here](/smart_light_esp32/README.md)

**Smart light Dart**

```sh
cd smart_light_dart
dart pub get
dart run
```

**Light controller**

```sh
cd light_controller
flutter pub get
flutter run
```

## Limitations

Only a single light is supported at a time.

Could be expanded with some sort of discovery of devices.
You could have a topic where devices (smart lights) can broadcast their
presence.
Then have a topic per device such that devices can be controlled individually.

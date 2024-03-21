# MQTT Example

Here is an example of how to use MQTT (v3) with dart/flutter.

There are two projects:

- **iot_light** Simulates a IoT "smart" light that can be turned on an off.
- **light_controller** is a flutter app using BLoC that can control the light.

I only tested using Mosquitto as broker.

## Server address

Check server address in `main.dart` files.

- Set to `10.0.2.2` when running in Android Emulator

# Getting started

**Broker**

```sh
mosquitto -c mosquitto.conf
```

**IoT Light**

```sh
cd iot_light
dart pub get
dart run
```

**Light controller**

```sh
cd light_controller
flutter pub get
flutter run
```

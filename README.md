# MQTT Example

Here is an example of how to use MQTT with dart/flutter.

There are two projects:

- **mqtt_source** is a dart console application that published whatever you type as a message.
- **mqtt_subscriber** is a flutter app using BLoC to listen for messages.

I only tested using Mosquitto as broker.

## Server address

Check server address in `mqtt_subscriber/lib/main.dart`.

- Set to `10.0.2.2` when running in Android Emulator
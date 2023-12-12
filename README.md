# MQTT Example

Here is an example of how to use MQTT with dart/flutter.

There are two projects:

- **mqtt_source** is a dart console application that published whatever you type as a message.
- **mqtt_subscriber** is a flutter app using BLoC to listen for messages.

**Remember to change server address**

I only tested using Mosquitto as broker.

## Connection problems

Android Emulator networking is isolated from the host network.
This makes it awkward to run message broker on your development machine.

Either use a broker on some cloud hosted service or run Flutter app on a real device.

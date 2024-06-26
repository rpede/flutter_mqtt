import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:light_protocol/light_protocol.dart';

import 'light_bulb.dart';

const server = "localhost";
const port = 1883;

Future<void> waitForEnter() {
  return stdin
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .takeWhile((line) => line.isNotEmpty)
      .drain();
}

void main(List<String> arguments) async {
  final device = LightBulb();

  final mqttClient = MqttServerClient.withPort(server, "smart-light-bulb", port);
  // client.logging(on: true);
  await mqttClient.connect(/* credentials */);
  final protocol = DeviceProtocol(device: device, mqttClient: mqttClient);

  await waitForEnter();

  await protocol.dispose();
  mqttClient.disconnect();
}

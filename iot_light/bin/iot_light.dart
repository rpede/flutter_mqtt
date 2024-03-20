import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_protocol/mqtt_protocol.dart';

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

  final client = MqttServerClient.withPort(server, "smart-light-bulb", port);

  // client.logging(on: true);
  await client.connect(/* credentials */);
  client.subscribe(deviceTopic, MqttQos.atLeastOnce);
  final adapter = MqttJsonAdapter(
    client: client,
    protocol: DeviceProtocol(
      device: device,
      controllerTopic: controllerTopic,
    ),
  );

  await waitForEnter();

  await adapter.dispose();
  client.disconnect();
}

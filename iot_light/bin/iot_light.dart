import 'dart:io';

import 'package:iot_light/mqtt_json_adapter.dart';
import 'package:iot_light/protocol.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'light_bulb.dart';

const server = "localhost";
const port = 1883;

void main(List<String> arguments) async {
  final device = LightBulb();

  final client = MqttServerClient.withPort(server, "smart-light-bulb", port);

  client.logging(on: true);
  await client.connect(/* credentials */);
  client.subscribe(deviceTopic, MqttQos.atLeastOnce);
  final adapter = MqttJsonAdapter(
    client: client,
    protocol: DeviceProtocol(
      device: device,
      controllerTopic: controllerTopic,
    ),
  );

  String? input;
  do {
    print("Press 'q' to exit");
    input = stdin.readLineSync();
  } while (input != 'q');

  await adapter.dispose();
  client.disconnect();
}

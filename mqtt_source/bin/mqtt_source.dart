import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_source/mqtt_publisher.dart';

const topic = 'messages';

void main(List<String> arguments) async {
  final publisher = MqttPublisher(
      MqttServerClient.withPort("localhost", "dart_source", 1883));

  try {
    await publisher.connect();

    print('Type messages, end with "q"');
    String? input;
    do {
      input = stdin.readLineSync();
      publisher.publishMessage(topic: 'messages', message: input!);
    } while (input != 'q');
  } on NoConnectionException catch (e) {
    print('MQTTClient::Client exception - $e');
    publisher.disconnect();
  } on SocketException catch (e) {
    print('MQTTClient::Socket exception - $e');
    publisher.disconnect();
  }
}

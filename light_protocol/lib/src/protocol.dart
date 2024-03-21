import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'device.dart';
import 'messages.dart';
import 'json_mqtt_client_extension.dart';

const controllerTopic = 'light-controller';
const deviceTopic = 'light-bulb';
const qos = MqttQos.atLeastOnce;

/// Implements the device side of the protocol.
class DeviceProtocol {
  final Device device;
  final MqttClient mqttClient;
  late StreamSubscription<DeviceStatus> _subscription;

  DeviceProtocol({required this.mqttClient, required this.device}) {
    mqttClient.subscribe(deviceTopic, qos);
    _subscription = mqttClient
        .jsonUpdates(fromJson: Command.fromJson)
        .asyncMap((event) async {
      final command = event.message;
      switch (command.action) {
        case Action.turnOn:
          await device.turnOn();
          break;
        case Action.turnOff:
          await device.turnOff();
          break;
        case Action.reportStatus:
          break;
      }
      return DeviceStatus(device.power);
    }).listen((status) {
      mqttClient.publishJsonMessage(controllerTopic, status.toJson());
    });
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}

// Implements the controller (Flutter app) side of the protocol.
class ControllerProtocol {
  final MqttClient mqttClient;

  ControllerProtocol({required this.mqttClient}) {
    mqttClient.subscribe(controllerTopic, qos);
  }

  Stream<DeviceStatus> get statusStream => mqttClient
      .jsonUpdates<DeviceStatus>(fromJson: DeviceStatus.fromJson)
      .map((event) => event.message);

  publishCommand(Command command) =>
      mqttClient.publishJsonMessage(deviceTopic, command.toJson());
}

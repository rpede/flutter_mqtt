import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:light_protocol/light_protocol.dart';

import 'iot_light_state.dart';

class IotLightBloc extends Cubit<AppState> {
  final MqttClient mqttClient;
  late ControllerProtocol protocol;
  late StreamSubscription<DeviceStatus> _subscription;

  IotLightBloc({required this.mqttClient}) : super(AppState.initial()) {
    mqttClient
      ..autoReconnect = true
      ..onConnected = (() => _connectionStatus(ConnectionStatus.connected))
      ..onDisconnected =
          (() => _connectionStatus(ConnectionStatus.disconnected))
      ..onAutoReconnect = (() => _connectionStatus(ConnectionStatus.connecting))
      ..onAutoReconnected =
          (() => _connectionStatus(ConnectionStatus.connected));
  }

  Future<void> connect([String? username, String? password]) async {
    await mqttClient.connect(username, password);

    protocol = ControllerProtocol(mqttClient: mqttClient);

    _subscription = protocol.statusStream.listen((status) {
      emit(state.copyWith(
        light: switch (status.power) {
          Power.on => LightStatus.on,
          Power.off => LightStatus.off
        },
      ));
    });
  }

  void _connectionStatus(ConnectionStatus status) {
    emit(state.copyWith(connection: status));
  }

  void switchLight(bool value) {
    protocol.publishCommand(Command(value ? Action.turnOn : Action.turnOff));
    emit(state.copyWith(light: LightStatus.unknown));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

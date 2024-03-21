import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:light_protocol/light_protocol.dart';

enum LightStatus {
  on,
  off,
  unknown,
}

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// Combines MQTT connection status with power status of IoT light.
class AppState {
  final ConnectionStatus connection;
  final LightStatus light;

  AppState({
    required this.connection,
    required this.light,
  });

  factory AppState.initial() {
    return AppState(
      connection: ConnectionStatus.disconnected,
      light: LightStatus.unknown,
    );
  }

  copyWith({ConnectionStatus? connection, LightStatus? light}) {
    return AppState(
      connection: connection ?? this.connection,
      light: light ?? this.light,
    );
  }
}

class IotLightBloc extends Cubit<AppState> {
  final MqttClient mqttClient;
  late ControllerProtocol protocol;
  late StreamSubscription<DeviceStatus> _subscription;

  IotLightBloc({required this.mqttClient}) : super(AppState.initial()) {
    mqttClient
      ..autoReconnect = true
      ..onConnected = (() => _connectionStatus(ConnectionStatus.connected))
      ..onDisconnected = (() => _connectionStatus(ConnectionStatus.disconnected))
      ..onAutoReconnect = (() => _connectionStatus(ConnectionStatus.connecting))
      ..onAutoReconnected = (() => _connectionStatus(ConnectionStatus.connected))
      ;
  }

  Future<void> connect() async {
    await mqttClient.connect(/* credentials */);

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
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

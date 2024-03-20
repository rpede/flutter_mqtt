import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_protocol/mqtt_protocol.dart';

enum ConnectionStatus {
  connecting,
  connected,
  listening,
  disconnecting,
  disconnected,
}

enum LightStatus {
  on,
  off,
  unknown,
}

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

class MqttBloc extends Cubit<AppState> with ControllerProtocol {
  final MqttClient client;
  MqttBloc({required this.client}) : super(AppState.initial()) {
    client
      ..onConnected = (() => connection(ConnectionStatus.connected))
      ..onDisconnected = (() => connection(ConnectionStatus.disconnected))
      ..onSubscribed = ((topic) => connection(ConnectionStatus.listening));
  }

  connection(ConnectionStatus connection) {
    emit(state.copyWith(connection: connection));
  }

  @override
  initialize(PublishMessage<Command> publish) {
    publish(deviceTopic, const Command(Action.reportStatus));
  }

  @override
  processMessage(
      String topic, Status messageIn, PublishMessage<Command> publish) {
    emit(state.copyWith(
      light: switch (messageIn.status) {
        Power.on => LightStatus.on,
        Power.off => LightStatus.off
      },
    ));
  }

  void switchLight(bool value) {
    // TODO
  }
}

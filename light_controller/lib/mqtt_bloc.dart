import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_protocol/messages.dart';
import 'package:mqtt_protocol/mqtt_protocol.dart';
import 'package:mqtt_protocol/protocol.dart';

enum LightStatus {
  on,
  off,
  unknown,
}

class AppState {
  final MqttConnectionState connection;
  final LightStatus light;

  AppState({
    required this.connection,
    required this.light,
  });

  factory AppState.initial() {
    return AppState(
      connection: MqttConnectionState.disconnected,
      light: LightStatus.unknown,
    );
  }

  copyWith({MqttConnectionState? connection, LightStatus? light}) {
    return AppState(
      connection: connection ?? this.connection,
      light: light ?? this.light,
    );
  }
}

class MqttBloc extends Cubit<AppState> with ControllerProtocol {
  final MqttServerClient client;
  late MqttJsonAdapter adapter;
  late PublishMessage<Command> publish;

  MqttBloc({required this.client}) : super(AppState.initial()) {
    client
      ..onConnected = (() => connection(MqttConnectionState.connected))
      ..onDisconnected = (() => connection(MqttConnectionState.disconnected));
    adapter = MqttJsonAdapter(client: client, protocol: this);
  }

  connection(MqttConnectionState connection) {
    emit(state.copyWith(connection: connection));
  }

  @override
  initialize(PublishMessage<Command> publish) {
    this.publish = publish;
    publish(deviceTopic, const Command(Action.reportStatus));
    emit(state.copyWith(
      connection:
          client.connectionStatus?.state ?? MqttConnectionState.disconnected,
    ));
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
    publish(deviceTopic, Command(value ? Action.turnOn : Action.turnOff));
  }
}

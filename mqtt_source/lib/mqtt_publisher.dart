import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttPublisher {
  final MqttServerClient _client;

  MqttPublisher(this._client);

  connect() async {
    _client.connectionMessage =
        MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    _client
      ..logging(on: true)
      ..keepAlivePeriod = 60
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..pongCallback = _pong;

    await _client.connect();
  }

  int publishMessage({required String topic, required String message}) {
    final builder = MqttClientPayloadBuilder()..addString(message);
    return _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  disconnect() {
    _client.disconnect();
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _pong() {
    print('PONG!');
  }
}

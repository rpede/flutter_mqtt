import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_subscriber/mqtt_bloc.dart';

typedef MqttUpdates = List<MqttReceivedMessage<MqttMessage>>;

class MqttSubscriber {
  final MqttServerClient client;
  final String topic;
  final void Function(AppEvent event) onEvent;
  StreamSubscription<MqttUpdates>? _listenSub;

  MqttSubscriber({
    required this.client,
    required this.topic,
    required this.onEvent,
  }) {
    client.connectionMessage =
        MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    client
      ..logging(on: true)
      ..keepAlivePeriod = 60
      ..onConnected = (() => onEvent(Connected()))
      ..onDisconnected = (() => onEvent(Disconnected()))
      ..onSubscribed = ((topic) => onEvent(Subscribed(topic)))
      ..pongCallback = (() => onEvent(Pong()));
  }

  connect() async {
    await client.connect();
    client.subscribe(topic, MqttQos.atLeastOnce);
    _listenSub = client.updates!.listen((MqttUpdates? updates) {
      print('Listen was called!');
      for (final update in updates!) {
        final message = update.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        onEvent(Message(message: payload));
      }
    });
  }

  void disconnect() {
    client.unsubscribe(topic);
    // _listenSub?.cancel();
    client.disconnect();
  }
}

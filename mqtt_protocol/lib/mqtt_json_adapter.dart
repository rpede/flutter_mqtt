import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef PublishMessage<Tout> = int Function(String topic, Tout messageOut);

abstract class JsonProtocol<Tin, Tout> {
  initialize(PublishMessage<Tout> publish) {}
  processMessage(String topic, Tin messageIn, PublishMessage<Tout> publish);
  Tin convertFromJsonIn(String topic, dynamic jsonIn);
  dynamic convertToJsonOut(String topic, Tout messageOut);
}

class MqttJsonAdapter<Tin, Tout> {
  final MqttServerClient client;
  final JsonProtocol<Tin, Tout> protocol;
  late StreamSubscription? _subscription;

  MqttJsonAdapter({required this.client, required this.protocol}) {
    _listenForUpdates();
    protocol.initialize(publishMessage);
  }

  /// Listen for updates on subscribed topics
  _listenForUpdates() {
    _subscription = client.updates?.listen((updates) {
      for (final update in updates) {
        // Get payload from update
        final mqttMessage = update.payload as MqttPublishMessage;
        final topic = update.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
            mqttMessage.payload.message);

        // Deserialize JSON
        final json = jsonDecode(payload);
        final message = protocol.convertToJsonOut(topic, json);

        // Forward protocol
        protocol.processMessage(topic, message, publishMessage);
      }
    });
  }

  /// Callback for publishing a message
  int publishMessage(String topic, Tout messageOut) {
    // Serialize message json
    final payload = jsonEncode(protocol.convertToJsonOut(topic, messageOut));
    final builder = MqttClientPayloadBuilder()..addString(payload);
    // Publish serialized message to topic
    return client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}

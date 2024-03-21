import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';

typedef JsonMessage<T> = ({String topic, T message});

extension JsonMqttClientX on MqttClient {
  Stream<JsonMessage<T>> jsonUpdates<T>(
          {required T Function(Map<String, dynamic> json) fromJson}) =>
      updates!.expand((updates) sync* {
        for (final update in updates) {
          // Get payload from update
          final mqttMessage = update.payload as MqttPublishMessage;
          final topic = update.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
              mqttMessage.payload.message);

          // Deserialize JSON
          print("Update payload: $payload");
          final json = jsonDecode(payload);
          final message = fromJson(json);

          // Forward protocol
          yield (topic: topic, message: message);
        }
      });

  /// Callback for publishing a message
  int publishJsonMessage<T>(String topic, Map<String, dynamic> json) {
    // Serialize message json
    final payload = jsonEncode(json);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    // Publish serialized message to topic
    return publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_subscriber.dart';

enum Status {
  connecting,
  connected,
  listening,
  disconnecting,
  disconnected,
}

class AppState {
  final Status status;
  final bool activated;
  final List<String> messages;
  final int maxLength;

  AppState({
    required this.status,
    required this.activated,
    required this.messages,
    required this.maxLength,
  });

  factory AppState.initial({int maxLength = 50}) {
    return AppState(
      activated: false,
      status: Status.disconnected,
      messages: [],
      maxLength: maxLength,
    );
  }

  copyWith({Status? status, bool? activated, String? message}) {
    return AppState(
        status: status ?? this.status,
        activated: activated ?? this.activated,
        messages:
            message == null ? messages : [message, ...messages.take(maxLength)],
        maxLength: maxLength);
  }
}

abstract class AppEvent {}

class Activate extends AppEvent {
  final bool activate;
  Activate(this.activate);
}

class Connected extends AppEvent {}

class Disconnected extends AppEvent {}

class Subscribed extends AppEvent {
  final String topic;

  Subscribed(this.topic);
}

class Pong extends AppEvent {}

class Message extends AppEvent {
  final String message;

  Message({required this.message});
}

class MqttBloc extends Bloc<AppEvent, AppState> {
  late MqttSubscriber _subscriber;

  StreamSubscription<MqttUpdates>? _updatesSubscription;

  MqttBloc(
      {required String server, required String clientIdentifier, int? port})
      : super(AppState.initial()) {
    final client = MqttServerClient(server, clientIdentifier);
    if (port != null) {
      client.port = port;
    }

    _subscriber =
        MqttSubscriber(client: client, topic: 'messages', onEvent: add);

    on<Activate>((event, emit) {
      if (event.activate) {
        emit(state.copyWith(
            status: Status.connecting, activated: event.activate));
        _subscriber.connect();
      } else {
        emit(state.copyWith(
            status: Status.disconnecting, activated: event.activate));
        _subscriber.disconnect();
      }
    });

    on<Connected>((event, emit) {
      emit(state.copyWith(status: Status.connected));
    });

    on<Disconnected>((event, emit) async {
      emit(state.copyWith(status: Status.disconnected));
      await _updatesSubscription?.cancel();
      _updatesSubscription = null;
    });

    on<Subscribed>((event, emit) {
      emit(state.copyWith(status: Status.listening));
    });

    on<Pong>(
      (event, emit) => print(event.toString()),
    );

    on<Message>((event, emit) {
      emit(state.copyWith(message: event.message));
    });
  }

  @override
  close() async {
    _subscriber.disconnect();
    super.close();
  }
}

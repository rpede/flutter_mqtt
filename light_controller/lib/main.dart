import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:light_controller/mqtt_bloc.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:light_protocol/light_protocol.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const serverForEmulator = "10.0.2.2";
const server = "localhost";
const port = 1883;
const wsPort = 8080;

MqttClient createClient() {
  if (kIsWeb) {
    return MqttBrowserClient.withPort("ws://$server/", 'light-controller-app', wsPort);
  } else if (Platform.isAndroid) {
    return MqttServerClient.withPort(
        serverForEmulator, 'light-controller-app', port);
  } else {
    return MqttServerClient.withPort(server, 'light-controller-app', port);
  }
}

void main() async {
  final client = createClient();

  client.logging(on: true);
  await client.connect(/* credentials */);
  client.subscribe(controllerTopic, MqttQos.atLeastOnce);

  runApp(BlocProvider<MqttBloc>(
    create: (context) => MqttBloc(client: client),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocBuilder<MqttBloc, AppState>(
        builder: (context, state) {
          final h1 = Theme.of(context).textTheme.displayLarge;
          return Scaffold(
            appBar: AppBar(title: Text("Connection: ${state.connection.name}")),
            body: Center(
              child: Column(
                children: [
                  Text(
                    switch (state.light) {
                      LightStatus.on => "💡",
                      LightStatus.off => "🌃",
                      LightStatus.unknown => "🤔"
                    },
                    style: h1,
                  ),
                  Switch(
                      value: state.light == LightStatus.on,
                      onChanged: (value) {
                        context.read<MqttBloc>().switchLight(value);
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

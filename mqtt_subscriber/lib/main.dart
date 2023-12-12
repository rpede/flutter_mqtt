import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_subscriber/mqtt_bloc.dart';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: BlocProvider(
          create: (context) => MqttBloc(
            server: '192.168.1.117',
            clientIdentifier: 'flutter_subscriber',
            port: 1883,
          ),
          child: const MessageWidget(),
        ));
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MqttBloc>(context);
    return BlocBuilder<MqttBloc, AppState>(
      builder: (context, state) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('${state.status}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Activate'),
                      Switch(
                          value: state.activated,
                          onChanged: (activate) =>
                              bloc.add(Activate(activate))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: _buildMessageTile,
                itemCount: bloc.state.messages.length,
              ),
            )
          ],
        ),
    );
  }

  Widget _buildMessageTile(context, index) {
    final bloc = BlocProvider.of<MqttBloc>(context);
    final message = bloc.state.messages[index];
    return ListTile(title: Text(message));
  }
}

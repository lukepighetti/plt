import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_view.dart';

late final SharedPreferences prefs;

Future<void> main() async {
  prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plt',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _nameController = TextEditingController();
  late final _nameFocusNode = FocusNode();

  var _name = prefs.getString('name') ?? '';

  @override
  void initState() {
    print('initState');
    setupMqtt();
    super.initState();
  }

  final client = MqttBrowserClient('wss://plt-mqtt.ngrok.io', '');

  Future<void> setupMqtt() async {
    client.port = 443;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    try {
      print("Connecting to MQTT server");
      await client.connect();
      // dirty hax, dirty hax, dirty hax
      setState(() {});
      print("Connected to MQTT server");
    } catch (e) {
      print(e);
    }

    client.subscribe('#', MqttQos.atMostOnce);

    await for (final batch in client.updates!) {
      for (final message in batch) {
        final p = message.payload;
        if (p is! MqttPublishMessage) continue;
        final pt = MqttPublishPayload.bytesToStringAsString(p.payload.message);
        print('<${message.topic}>: $pt');
      }
    }
  }

  void _broadcastJoin(String name) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(name);
    client.publishMessage(
        'broadcast-join', MqttQos.atMostOnce, builder.payload!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() {
      prefs.setString('name', name);
      _name = name;
    });

    _broadcastJoin(name);
  }

  void _resetName() {
    final name = '';

    setState(() {
      prefs.setString('name', name);
      _name = name;
    });

    _broadcastJoin(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Game view
          GameView(),

          /// Status bar
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  if (_name.isNotEmpty)
                    TextButton(
                      child: Text(_name),
                      onPressed: () {
                        _resetName();
                      },
                    ),
                ],
              ),
            ),
          ),

          /// Enter your name
          if (_name.isEmpty)
            Center(
              child: SizedBox(
                height: 300,
                width: 400,
                child: Card(
                  elevation: 20,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: Colors.pink, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Call to action
                        Text(
                          "Choose your name",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),

                        /// Name text field
                        Padding(
                          padding: EdgeInsets.all(25),
                          child: TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            onSubmitted: (_) => _submitName(),
                            autofocus: true,
                            decoration:
                                InputDecoration(hintText: "Ligma Johnson"),
                          ),
                        ),

                        SizedBox(height: 25),

                        /// Proceed button
                        AnimatedBuilder(
                          animation: _nameController,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: _nameController.text.trim().isEmpty
                                  ? null
                                  : _submitName,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(25),
                                textStyle:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              child: Text("Let's goooo!"),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (client.connectionStatus?.state != MqttConnectionState.connected)
            ColoredBox(
              color: Colors.black87,
              child: Center(
                child: Text(
                  "Loading...",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

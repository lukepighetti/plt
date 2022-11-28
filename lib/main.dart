import 'dart:async';
import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'game_view.dart';
import 'logger.dart';

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
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static final _mqttLog = Logger('MQTT');
  late final usernameController = TextEditingController(text: userName);
  late final usernameFocusNode = FocusNode();

  var userName = prefs.getString('userName') ?? '';
  var userId = prefs.getString('userId') ?? '';

  @override
  void initState() {
    setupMqtt();

    if (userId.isEmpty) {
      userId = Uuid().v4();
      prefs.setString('userId', userId);
    }

    super.initState();
  }

  @override
  void dispose() {
    client.unsubscribe('#');
    subscription?.cancel();
    usernameController.dispose();
    usernameFocusNode.dispose();
    super.dispose();
  }

  final client = MqttBrowserClient('wss://plt-mqtt.ngrok.io', '');

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  StreamSubscription? subscription;
  Future<void> setupMqtt() async {
    client.port = 443;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    try {
      _mqttLog.i("Connecting to MQTT server");
      if (!isConnected) await client.connect();
      // dirty hax, dirty hax, dirty hax
      setState(() {});
      _mqttLog.i("Connected to MQTT server");
    } catch (e) {
      _mqttLog.e(e.toString());
    }

    client.subscribe('#', MqttQos.atMostOnce);

    // dirty hax, dirty hax, dirty hax
    if (userName.isNotEmpty) {
      broadcastName();
    }

    subscription?.cancel();
    subscription = client.updates!.listen((batch) {
      for (final message in batch) {
        final p = message.payload;
        if (p is! MqttPublishMessage) continue;
        final pt = MqttPublishPayload.bytesToStringAsString(p.payload.message);
        switch (message.topic) {
          case 'broadcast-name':
            _handleBroadcastName(pt);
            break;
          case 'broadcast-character-position':
            _handleBroadcastCharacterPosition(pt);
            break;
        }
        _mqttLog.v('<${message.topic}>: $pt');
      }
    });
  }

  final _userNameByUserId = <String, String>{};

  void broadcastName() {
    if (!isConnected) return;
    // TODO: pack/unpack different types of data, ie bool, int, string
    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode([userId, userName]));
    client.publishMessage(
        'broadcast-name', MqttQos.atMostOnce, builder.payload!);
  }

  void _handleBroadcastName(String pt) {
    final data = jsonDecode(pt);
    final userId = data[0];
    final userName = data[1];
    if (userId == this.userId) return;
    _userNameByUserId[userId] = userName;
  }

  final _userPositionByUserId = <String, Vector2>{};

  void broadcastCharacterPosition(Vector2 gameCoordinates) {
    if (!isConnected) return;
    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode([userId, gameCoordinates.toString()]));
    client.publishMessage(
        'broadcast-character-position', MqttQos.atMostOnce, builder.payload!);
  }

  void _handleBroadcastCharacterPosition(String pt) {
    final data = jsonDecode(pt);
    final userId = data[0];
    if (userId == this.userId) return;
    final gameCoordinates = jsonDecode(data[1]);
    final x = gameCoordinates[0];
    final y = gameCoordinates[1];
    _userPositionByUserId[userId] = Vector2(x, y);
  }

  void _submitName() {
    final name = usernameController.text.trim();
    if (name.isEmpty) {
      usernameFocusNode.requestFocus();
      return;
    }

    setState(() {
      prefs.setString('userName', name);
      userName = name;
    });

    broadcastName();
    gameFocusNode.requestFocus();
  }

  void _resetName() {
    final name = '';

    setState(() {
      prefs.setString('userName', name);
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Game view
          GameView(gameState: this),

          /// Status bar
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (userName.isNotEmpty)
                    TextButton(
                      child: Text(userName),
                      onPressed: () {
                        _resetName();
                      },
                    ),
                ],
              ),
            ),
          ),

          /// Enter your name
          if (userName.isEmpty)
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
                            controller: usernameController,
                            focusNode: usernameFocusNode,
                            onSubmitted: (_) => _submitName(),
                            autofocus: true,
                            decoration:
                                InputDecoration(hintText: "Ligma Johnson"),
                          ),
                        ),

                        SizedBox(height: 25),

                        /// Proceed button
                        AnimatedBuilder(
                          animation: usernameController,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: usernameController.text.trim().isEmpty
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

          if (!isConnected)
            ColoredBox(
              color: Colors.black26,
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

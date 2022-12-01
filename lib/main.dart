import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart' hide Timer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_view.dart';
import 'logger.dart';

late final SharedPreferences prefs;

const showMyGhost = kDebugMode;
const fakeJitter = 0;
const fakeDelay = 0;

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
  var sessionId = nanoid(2);
  Timer? nameBroadcastingTimer;

  @override
  void initState() {
    setupMqtt();

    if (userId.isEmpty) {
      userId = nanoid(4);
      prefs.setString('userId', userId);
    }

    nameBroadcastingTimer = Timer.periodic(
      Duration(seconds: 5),
      (_) => broadcastName(),
    );

    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocusNode.dispose();
    nameBroadcastingTimer?.cancel();
    super.dispose();
  }

  static final client = MqttBrowserClient('wss://plt-mqtt.ngrok.io', '');

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  static StreamSubscription? sub1;

  Future<void> setupMqtt() async {
    client.port = 443;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    try {
      _mqttLog.i("Connecting to MQTT server");
      await client.connect();
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

    sub1?.cancel();
    sub1 = client.updates!.listen((batch) {
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

  final userNameByUserId = <String, String>{};

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
    if (!showMyGhost && userId == this.userId) return;
    userNameByUserId[userId] = userName;
  }

  final userPositionByUserId = <String, PositionUpdate>{};

  final messageTime = Stopwatch()..start();

  void broadcastCharacterPosition(
    Vector2 position,
    Vector2 velocity,
    Vector2 acceleration,
  ) async {
    if (!isConnected) return;

    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode([
        messageTime.elapsedMilliseconds,
        userId,
        sessionId,
        position.toString(),
        velocity.toString(),
        acceleration.toString(),
      ]));

    if (fakeJitter > 0)
      await Future.delayed(
          Duration(milliseconds: Random().nextInt(fakeJitter)));
    if (fakeDelay > 0) await Future.delayed(Duration(milliseconds: fakeDelay));
    client.publishMessage(
        'broadcast-character-position', MqttQos.atMostOnce, builder.payload!);
  }

  void _handleBroadcastCharacterPosition(String pt) {
    final data = jsonDecode(pt);
    final elapsed = Duration(milliseconds: data[0]);
    final userId = data[1];
    final sessionId = data[2];
    if (!showMyGhost && userId == this.userId) return;
    final positionData = jsonDecode(data[3]);
    final position = Vector2(positionData[0], positionData[1]);
    final velocityData = jsonDecode(data[4]);
    final velocity = Vector2(velocityData[0], velocityData[1]);
    final accelerationData = jsonDecode(data[5]);
    final acceleration = Vector2(accelerationData[0], accelerationData[1]);
    userPositionByUserId[userId] =
        PositionUpdate(elapsed, sessionId, position, velocity, acceleration);
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

class PositionUpdate {
  final Duration elapsed;
  final String sessionId;
  final Vector2 position;
  final Vector2 velocity;
  final Vector2 acceleration;
  PositionUpdate(this.elapsed, this.sessionId, this.position, this.velocity,
      this.acceleration);
}

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plt/game_view_utils.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(gameFactory: () => MyGame());
  }
}

class MyGame extends Forge2DGame with SingleGameInstance {
  MyGame() {
    this.camera.zoom = 40.0;
  }

  late final Game game = findGame()!;
  late final ground = Ground();

  @override
  Future<void> onLoad() async {
    await add(Me());
    await add(ground);

    camera.followBodyComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }
}

class Me extends BodyComponent {
  final startPos = Vector2(1, -10);

  late var size = Vector2(0.5, 2.0);
  late var bodyDef = BodyDef(type: BodyType.dynamic, position: startPos);
  late var fixtureDef = FixtureDef(PolygonShape()..setAsBoxFromSize(size));
  late var massData = MassData()..mass = 90;
  final paint = Paint()..color = Colors.pink.shade300;

  @override
  Body createBody() {
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..setMassData(massData);
  }
}

class Ground extends BodyComponent {
  late var size = Vector2(1000, 25);

  late var bodyDef = BodyDef(type: BodyType.static, position: Vector2.zero());
  late var fixtureDef = FixtureDef(PolygonShape()..setAsBoxFromSize(size));
  final paint = Paint()..color = Colors.green;

  @override
  Body createBody() {
    return world.createBody(bodyDef)
      ..createFixture(
        fixtureDef,
      );
  }
}

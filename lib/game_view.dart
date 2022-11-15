import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'game_view_utils.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final game = MyGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}

class MyGame extends Forge2DGame with SingleGameInstance {
  MyGame() {
    // this.world.setGravity(Vector2(0, 9.8));
  }

  late final Game game = findGame()!;

  final me = MyCharacter();
  final horizon = _MyHorizonVisual();
  late final platforms = PositionComponent(
    position: Vector2(0, game.size.y),
    children: [
      _MyPlatformVisual(Vector2(05, -25)),
      _MyPlatformVisual(Vector2(15, -45)),
      _MyPlatformVisual(Vector2(25, -65)),
    ],
  );

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(horizon);
    await add(platforms);
    await add(FpsTextComponent());

    me.position = Vector2(15, game.size.y - 15);
    // horizon.position = Vector2(0, game.size.y - horizon.size.y);
    horizon.position = Vector2(0, 5);
  }
}

class MyCharacter extends BodyComponent {
  MyCharacter() {
    add(_MyCharacterVisual());
  }

  Vector2? position;

  @override
  Body createBody() {
    return world.createBody(
      BodyDef(type: BodyType.dynamic, position: position),
    )..createFixture(
        FixtureDef(CircleShape()),
      );
  }
}

class _MyCharacterVisual extends PlaceholderComponent {
  _MyCharacterVisual() {
    size = Vector2(5, 5);
    color = Colors.red;
  }
}

class MyHorizon extends BodyComponent {
  MyHorizon() {
    add(_horizon);
  }

  final _horizon = _MyHorizonVisual();

  Vector2? position;

  @override
  Body createBody() {
    return world.createBody(
      // TODO: make this BodyType.static
      BodyDef(type: BodyType.dynamic, position: position),
    )..createFixture(
        FixtureDef(
          PolygonShape()..setAsBoxXY(_horizon.size.x / 2, _horizon.size.y / 2),
        ),
      );
  }
}

class _MyHorizonVisual extends PlaceholderComponent {
  @override
  Future<void> onLoad() async {
    size = Vector2(findGame()!.size.x, 5);
    color = Colors.green;
  }
}

class MyPlatform extends BodyComponent {
  MyPlatform(Vector2 offset) {
    add(_MyPlatformVisual(offset));
  }

  Vector2? position;

  @override
  Body createBody() {
    return world.createBody(
      BodyDef(type: BodyType.dynamic, position: position),
    )..createFixture(
        FixtureDef(CircleShape()),
      );
  }
}

class _MyPlatformVisual extends PlaceholderComponent {
  _MyPlatformVisual(this.offset);

  final Vector2 offset;

  @override
  Future<void> onLoad() async {
    size = Vector2(25, 2);
    position = offset;
    color = Colors.orange;
  }
}

// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plt/game_view_utils.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(gameFactory: () => MyGame());
  }
}

class MyGame extends Forge2DGame with SingleGameInstance, KeyboardEvents {
  MyGame() {
    this.camera.zoom = 40.0;
    this.world.setGravity(Vector2(0, 40));
  }

  late final Game game = findGame()!;
  late final me = Me();
  late final ground = Ground();

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(ground);
    await add(FpsTextComponent());

    camera.followBodyComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }

  var _state = CharacterState.idle;

  @override
  void update(double dt) {
    final fx_i = me.body.force.x.abs();
    final vx_i = me.body.linearVelocity.x.abs();
    final fx_t = fx(vx_i);
    final fx_d = fx_t - fx_i;

    switch (_state) {
      case CharacterState.idle:
        me.body.clearForces();
        break;

      case CharacterState.moveLeft:
        me.body.applyForce(Vector2(-fx_d, 0));
        break;

      case CharacterState.moveRight:
        me.body.applyForce(Vector2(fx_d, 0));
        break;
    }
    super.update(dt);
  }

  static double fx(double vx) {
    final vx_max = 20.0;
    final fx_max = 8e3;
    final progress = (vx / vx_max).clamp(0.0, 1.0);
    final t = Curves.easeInOut.transform(progress);
    return lerpDouble(fx_max, 0, t)!;
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    print('$event, $keysPressed');
    if (event.repeat) return KeyEventResult.ignored;
    world.setAutoClearForces(false);

    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        me.body.applyLinearImpulse(Vector2(0, -1800));
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyL)) {
        _state = CharacterState.moveRight;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyH)) {
        _state = CharacterState.moveLeft;
        return KeyEventResult.handled;
      }
    }

    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyL) {
        _state = CharacterState.idle;
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyH) {
        _state = CharacterState.idle;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}

enum CharacterState {
  idle,
  moveLeft,
  moveRight,
}

class Me extends BodyComponent {
  final startPos = Vector2(1, -10);

  late var size = Vector2(0.8, 2.0);
  late var bodyDef = BodyDef(type: BodyType.dynamic, position: startPos);
  late var fixtureDef =
      FixtureDef(PolygonShape()..setAsBoxFromSize(size), friction: 0.9);
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
  late var fixtureDef = FixtureDef(
    PolygonShape()..setAsBoxFromSize(size),
    friction: 0.9,
  );
  final paint = Paint()..color = Colors.green;

  @override
  Body createBody() {
    return world.createBody(bodyDef)
      ..createFixture(
        fixtureDef,
      );
  }
}

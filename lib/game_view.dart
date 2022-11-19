// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keyboard_routing.dart';

final gameFocusNode = FocusNode();

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(
      gameFactory: () => MyGame(),
      focusNode: gameFocusNode,
    );
  }
}

class MyGame extends FlameGame
    with SingleGameInstance, KeyboardEvents, KeyboardRouting {
  MyGame() {
    this.camera.zoom = 40.0;
  }

  late final Game game = findGame()!;
  late final me = Character();
  late final ground = Ground();

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(ground);
    await add(FpsTextComponent());

    camera.followComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }

  final gravity = Vector2(0, 9.8);

  @override
  void update(double dt) {
    me.acceleration.setValues(0, 1);
    me.additionalVelocity.setFrom(
      Vector2.zero()
        ..add(Vector2(1, 0))
        ..add(Vector2(-2, 0)),
    );
    super.update(dt);
  }

  final keyboardRouter = KeyboardRouter(
    {
      LogicalKeyboardKey.space: () {},
    },
    {
      LogicalKeyboardKey.keyL: PressRouter(
        onDown: () {},
        onUp: () {},
      ),
      LogicalKeyboardKey.keyH: PressRouter(
        onDown: () {},
        onUp: () {},
      ),
    },
  );
}

class Character extends RectangleComponent with LinearMotion {
  Character()
      : super(
          position: Vector2(1, -10),
          size: Vector2(0.8, 2.0),
          paint: Paint()..color = Colors.pink.shade300,
        );
}

mixin LinearMotion on PositionComponent {
  var velocity = Vector2.zero();
  var additionalVelocity = Vector2.zero();
  var acceleration = Vector2.zero();
  var _debugStats = TextComponent(scale: Vector2.all(0.02));

  @override
  Future<void> onLoad() async {
    await add(_debugStats);
    super.onMount();
  }

  @override
  void update(double dt) {
    velocity += acceleration * dt;
    position += (velocity + additionalVelocity) * dt;

    _debugStats.text = 'P: ${position.toStringAsFixed(2)}\n'
        'V: ${velocity.toStringAsFixed(2)}\n'
        'A: ${acceleration.toStringAsFixed(2)}\n'
        '';

    super.update(dt);
  }
}

class Ground extends RectangleComponent {
  Ground()
      : super(
          position: Vector2.zero(),
          anchor: Anchor.topLeft,
          size: Vector2(1000, 0.1),
          paint: Paint()..color = Colors.green,
        );
}

extension on Vector2 {
  String toStringAsFixed(int fractionDigits) => [
        x.toStringAsFixed(fractionDigits),
        y.toStringAsFixed(fractionDigits)
      ].toString();
}

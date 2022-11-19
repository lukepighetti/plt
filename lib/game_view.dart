// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plt/game_view_utils.dart';

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

class CharacterStateEvents {
  var x = CharacterStateX.idle;
  var eventQueue = FifoQueue<CharacterEvent>();
}

enum CharacterEvent {
  jump,
}

class MyGame extends Forge2DGame with SingleGameInstance, KeyboardEvents {
  MyGame() {
    this.camera.zoom = 40.0;
    this.world.setGravity(Vector2(0, 40));
  }

  late final Game game = findGame()!;
  late final me = Me();
  late final ground = Ground();

  late final characterStates = {'me': CharacterStateEvents()};

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(ground);
    await add(FpsTextComponent());

    camera.followBodyComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }

  final v_max = 5;
  final double running_force = 10000;
  final double jump_impulse = 2e3;

  @override
  void update(double dt) {
    final _state = characterStates['me']!;

    switch (_state.x) {
      case CharacterStateX.idle:
        break;

      case CharacterStateX.movingLeft:
        if (me.body.linearVelocity.x.abs() > v_max) break;
        me.body.applyForce(Vector2(-running_force, 0));
        break;

      case CharacterStateX.movingRight:
        if (me.body.linearVelocity.x.abs() > v_max) break;
        me.body.applyForce(Vector2(running_force, 0));
        break;
    }

    if (_state.eventQueue.hasItems) {
      print('has items');
      for (final event in _state.eventQueue.popAll()) {
        switch (event) {
          case CharacterEvent.jump:
            print('JUMP');
            me.body.applyLinearImpulse(Vector2(0, -jump_impulse));
            break;
        }
      }
    }

    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // print('$event, $keysPressed');
    if (event.repeat) return KeyEventResult.ignored;

    final state = characterStates['me']!;

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        state.eventQueue.add(CharacterEvent.jump);
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyL)) {
        state.x = CharacterStateX.movingRight;
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyH)) {
        state.x = CharacterStateX.movingLeft;
        return KeyEventResult.handled;
      }
    }

    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyL) {
        state.x = CharacterStateX.idle;
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyH) {
        state.x = CharacterStateX.idle;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}

enum CharacterStateX {
  idle,
  movingLeft,
  movingRight,
}

enum CharacterStateY {
  idle,
  jumping,
}

class Me extends BodyComponent {
  final startPos = Vector2(1, -10);

  late var size = Vector2(0.8, 2.0);
  late var bodyDef = BodyDef(type: BodyType.dynamic, position: startPos);
  late var fixtureDef =
      FixtureDef(PolygonShape()..setAsBoxFromSize(size), friction: 0.8);
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
    friction: 0.1,
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

// class RunningForces {
//   RunningForces({
//     required this.vx_max,
//     required this.fx_max,
//   });

//   ///  Eg: 10.0
//   final double vx_max;

//   /// Eg: 8e4
//   final double fx_max;

//   double _fx(double vx) {
//     final progress = (vx / vx_max).clamp(0.0, 1.0);
//     final t = Curves.easeInOut.transform(progress);
//     return lerpDouble(fx_max, 0, t)!;
//   }

//   double run_x(Body body) {
//     final fx_i = body.force.x.abs();
//     final vx_i = body.linearVelocity.x.abs();
//     final fx_t = _fx(vx_i);
//     final fx_d = fx_t - fx_i;
//     return fx_d;
//   }

//   void applyMovingLeft(BodyComponent component) {
//     component.body.applyForce(Vector2(-run_x(component.body), 0));
//   }

//   void applyMovingRight(BodyComponent component) {
//     component.body.applyForce(Vector2(run_x(component.body), 0));
//   }
// }

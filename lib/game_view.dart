import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plt/mobile_controller.dart';

import 'collision_routing.dart';
import 'keyboard_routing.dart';
import 'main.dart';

final gameFocusNode = FocusNode();

class GameView extends StatelessWidget {
  const GameView({super.key, required this.gameState});

  final MyHomePageState gameState;

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(
      gameFactory: () => MyGame(state: gameState),
      focusNode: gameFocusNode,
    );
  }
}

class MyGame extends FlameGame
    with
        HasCollisionDetection,
        HasDraggables,
        HasTappables,
        KeyboardEvents,
        KeyboardRouting,
        MobileControllerEvents,
        MobileControllerRouting,
        SingleGameInstance {
  MyGame({required this.state}) {
    this.camera.zoom = 40.0;
  }

  late final Game game = findGame()!;
  final MyHomePageState state;
  final me = LocallyControlledCharater();
  final ground = Ground();
  final mobileControllerLeft = MobileControllerLeft();
  final mobileControllerRight = MobileControllerRight();
  final remoteCharacters = <String, RemoteControlledCharacter>{};

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(ground);
    await add(FpsTextComponent());
    await add(OffscreenCharacter(me));
    await add(mobileControllerLeft);
    await add(mobileControllerRight);
    camera.followComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }

  @override
  void update(double dt) {
    final userIds = state.userNameByUserId.keys;

    for (final userId in userIds) {
      final character = remoteCharacters[userId];
      if (character == null) {
        final newCharacter = RemoteControlledCharacter(state, userId);
        remoteCharacters[userId] = newCharacter;
        add(newCharacter);
      }
    }

    super.update(dt);
  }

  late final keyboardRouter = KeyboardRouter(
    keyAliases: {
      LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyH: LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyK: LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.keyL: LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.space: LogicalKeyboardKey.arrowUp,
    },
    handlePress: {
      LogicalKeyboardKey.arrowUp: ButtonRouter(
        onDown: () => me.thrusting.buttonValue = true,
        onUp: () => me.thrusting.buttonValue = false,
      ),
      LogicalKeyboardKey.arrowRight: ButtonRouter(
        onDown: () => me.movingRight.buttonValue = true,
        onUp: () => me.movingRight.buttonValue = false,
      ),
      LogicalKeyboardKey.arrowLeft: ButtonRouter(
        onDown: () => me..movingLeft.buttonValue = true,
        onUp: () => me.movingLeft.buttonValue = false,
      ),
    },
  );

  @override
  late final mobileControllerRouter = MobileControllerRouter(
    supportedStickDirections: {AxisDirection.left, AxisDirection.right},
    handleStickChanged: (vector) {
      if (vector.x > 0) {
        me.movingRight.joystickValue = vector.x;
      } else {
        me.movingRight.joystickValue = 0;
      }

      if (vector.x < 0) {
        me.movingLeft.joystickValue = -vector.x;
      } else {
        me.movingLeft.joystickValue = 0;
      }
    },
    handlePress: {
      MobileControllerButton.primary:
          keyboardRouter.handlePress[LogicalKeyboardKey.arrowUp]!,
    },
  );
}

class OffscreenCharacter extends PositionComponent with HasGameRef<MyGame> {
  OffscreenCharacter(this.characterRef);

  final Character characterRef;

  late final paint = characterRef.paint;

  static const r = 0.2;

  late final characterPoint = PositionComponent(
    children: [
      CircleComponent(
        radius: r,
        anchor: Anchor.center,
        paint: paint,
      ),
      PolygonComponent(
        [Vector2(-r, -r), Vector2(0, -r), Vector2(-r, 0)],
        size: Vector2.all(0.4),
        anchor: Anchor.center,
        paint: paint,
        angle: 1 * pi / 4,
      ),
    ],
  );

  late final boundary = RectangleComponent(
    size: _getBoundarySize(),
    position: _getBoundaryPosition(),
    paint: Paint()..color = Colors.transparent,
  );

  late final camera = gameRef.camera;
  late final padding = Vector2.all(0.5);

  Vector2 _getBoundarySize() => camera.gameSize - padding * 2;
  Vector2 _getBoundaryPosition() => camera.position + padding;

  @override
  Future<void>? onLoad() async {
    await add(characterPoint);
    await add(boundary);
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    boundary.position.setFrom(_getBoundaryPosition());
    boundary.sizeSetFromShim(_getBoundarySize());
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    final cameraCenter = camera.position + camera.gameSize / 2;
    final characterCenter = characterRef.position + characterRef.size / 2;
    final lineTo = LineSegment(cameraCenter, characterCenter);
    characterPoint.angle = (characterCenter - cameraCenter).screenAngle();
    characterPoint.position.setFrom(characterCenter);
    final intersection = boundary.intersectionWith(lineTo);
    if (intersection != null) characterPoint.position.setFrom(intersection);
    super.update(dt);
  }
}

class RemoteControlledCharacter extends Character with RemoteCharacterControl {
  RemoteControlledCharacter(this.state, this.userId);

  @override
  final MyHomePageState state;

  @override
  final String userId;
}

mixin RemoteCharacterControl on Character {
  MyHomePageState get state;

  String get userId;

  final remoteAcceleration = Vector2.zero();

  late var updatedAt = DateTime.now();

  @override
  void update(double dt) {
    final newPosition = state.userPositionByUserId.remove(userId);
    if (newPosition != null && newPosition.sentAt.isAfter(updatedAt)) {
      position.setFrom(newPosition.position);
      velocity.setFrom(newPosition.velocity);

      remoteAcceleration.setFrom(newPosition.acceleration);
      updatedAt = newPosition.sentAt;
    }

    velocity.add(remoteAcceleration * dt);
    super.update(dt);
  }
}

class LocallyControlledCharater = Character with LocalCharacterControl;

mixin LocalCharacterControl on Character {
  var thrusting = JoystickButtonValue();
  var movingLeft = JoystickButtonValue();
  var movingRight = JoystickButtonValue();

  void onNetworkUpdate(Vector2 acceleration) {
    _dtSinceNetworkUpdate = 0.0;
    gameRef.state.broadcastCharacterPosition(position, velocity, acceleration);
  }

  static const _networkUpdatePeriod = 0.5;

  var _dtSinceNetworkUpdate = 0.0;

  final lastAcceleration = Vector2.zero();
  @override
  void update(double dt) {
    final acceleration = thrust.scaled(thrusting.value) +
        moveLeft.scaled(movingLeft.value) +
        moveRight.scaled(movingRight.value);

    velocity.add(acceleration * dt);

    // network updates
    _dtSinceNetworkUpdate += dt;
    if (_dtSinceNetworkUpdate > _networkUpdatePeriod ||
        lastAcceleration != acceleration) {
      onNetworkUpdate(acceleration);
    }

    lastAcceleration.setFrom(acceleration);
    super.update(dt);
  }
}

abstract class Character extends RectangleComponent
    with CollisionCallbacks, CollisionRouting, HasGameRef<MyGame> {
  Character()
      : super(
          position: Vector2(1, -10),
          size: Vector2(0.8, 2.0),
          paint: Paint()..color = Colors.pink.shade300,
        );

  final gravity = Vector2(0, 10);
  final thrust = Vector2(0, -90);
  final moveLeft = Vector2(-50, 0);
  late final moveRight = Vector2(-moveLeft.x, moveLeft.y);
  final maxVelocity = Vector2.all(40);

  late final position = super.position;
  final velocity = Vector2.zero();
  final damping = Vector2.all(1.5);

  Vector2? groundedPosition;

  bool get grounded => groundedPosition != null;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size));
  }

  @override
  void update(double dt) {
    // kinematics
    velocity.add(gravity * dt);
    velocity.damp(damping, dt);
    velocity.limit(maxVelocity);
    position.add(velocity * dt);

    // collisions
    if (groundedPosition != null) {
      position.y = min(groundedPosition!.y, position.y);
      position.x = groundedPosition!.x;
      velocity.setZero();
    }

    super.update(dt);
  }

  @override
  late final collisionRouter = CollisionRouter(
    handleType: {
      Ground: CollideRouter(
        onStart: (other) =>
            groundedPosition = Vector2(position.x, other.position.y - size.y),
        onEnd: (_) => groundedPosition = null,
      ),
    },
  );
}

class Ground extends RectangleComponent {
  Ground()
      : super(
          position: Vector2.zero(),
          anchor: Anchor.topLeft,
          size: Vector2(1000, 0.1),
          paint: Paint()..color = Colors.green,
        );

  @override
  Future<void>? onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}

extension Vector2X on Vector2 {
  void damp(Vector2 damping, double dt) {
    setFrom(Vector2(
      x / (1 + damping.x * dt),
      y / (1 + damping.y * dt),
    ));
  }

  void limit(Vector2 maximum) {
    clamp(-maximum, maximum);
  }
}

extension RectangleComponentX on RectangleComponent {
  Vector2? intersectionWith(LineSegment segment) {
    return possibleIntersectionVertices(null)
        .map((r) => r.intersections(segment))
        .where((r) => r.isNotEmpty)
        .singleOrNull
        ?.singleOrNull;
  }

  /// A shim for issue https://github.com/flame-engine/flame/pull/2167
  void sizeSetFromShim(Vector2 size) {
    size.setFrom(size);
    // ignore: invalid_use_of_protected_member
    refreshVertices(
      // ignore: invalid_use_of_protected_member
      newVertices: RectangleComponent.sizeToVertices(size, anchor),
    );
  }
}

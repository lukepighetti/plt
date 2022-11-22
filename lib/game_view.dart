import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'collision_routing.dart';
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
    with
        HasCollisionDetection,
        KeyboardEvents,
        KeyboardRouting,
        SingleGameInstance {
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
    await add(OffscreenCharacter(me));
    camera.followComponent(ground, relativeOffset: Anchor(0.05, 0.95));
  }

  @override
  void update(double dt) {
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
      LogicalKeyboardKey.arrowUp: KeyRouter(
        onDown: () => me.thrusting = true,
        onUp: () => me.thrusting = false,
      ),
      LogicalKeyboardKey.arrowRight: KeyRouter(
        onDown: () => me..movingRight = true,
        onUp: () => me.movingRight = false,
      ),
      LogicalKeyboardKey.arrowLeft: KeyRouter(
        onDown: () => me..movingLeft = true,
        onUp: () => me.movingLeft = false,
      ),
    },
  );
}

class OffscreenCharacter extends PositionComponent with HasGameRef<MyGame> {
  OffscreenCharacter(this.characterRef);

  final Character characterRef;

  final paint = Paint()..color = Colors.purple;

  late final centerPoint = CircleComponent(
    radius: 0.2,
    anchor: Anchor.center,
    paint: Paint()..color = Colors.red,
  );

  static const r = 0.2;

  late final characterPoint = PositionComponent(
    anchor: Anchor.center,
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
        angle: -3 * pi / 4,
      ),
    ],
  );

  @override
  Future<void>? onLoad() async {
    await add(centerPoint);
    await add(characterPoint);
    return super.onLoad();
  }

  late final camera = gameRef.camera;
  late final padding = Vector2.all(0.5);

  @override
  void update(double dt) {
    final cameraCenter = camera.position + camera.gameSize / 2;
    final characterCenter = characterRef.position + characterRef.size / 2;
    final upperLeft = camera.position + padding;
    final lowerRight = camera.position + camera.gameSize - padding;
    centerPoint.position.setFrom(cameraCenter);
    characterPoint.angle = (characterCenter - cameraCenter).screenAngle();
    characterPoint.position.setFrom(characterCenter);

    // TODO: don't clamp, find intersecton with viewport bounds
    characterPoint.position.clamp(upperLeft, lowerRight);

    super.update(dt);
  }
}

class Character extends RectangleComponent
    with CollisionCallbacks, CollisionRouting {
  Character()
      : super(
          position: Vector2(1, -10),
          size: Vector2(0.8, 2.0),
          paint: Paint()..color = Colors.pink.shade300,
        );

  static final gravity = Vector2(0, 10);
  static final thrust = Vector2(0, -90);
  static final moveLeft = Vector2(-50, 0);
  static final moveRight = Vector2(-moveLeft.x, moveLeft.y);
  static final maxVelocity = Vector2.all(40);

  late final position = super.position;
  final velocity = Vector2.zero();
  final damping = Vector2.all(1.5);

  var thrusting = false;
  var movingLeft = false;
  var movingRight = false;
  Vector2? groundedPosition;

  bool get grounded => groundedPosition != null;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size));
  }

  @override
  void update(double dt) {
    // kinematics
    if (thrusting) velocity.setFrom(velocity + thrust * dt);
    if (movingLeft) velocity.setFrom(velocity + moveLeft * dt);
    if (movingRight) velocity.setFrom(velocity + moveRight * dt);
    velocity.setFrom(velocity + gravity * dt);
    velocity.damp(damping, dt);
    velocity.limit(maxVelocity);
    position.setFrom(position + velocity * dt);

    // collisions
    if (groundedPosition != null && !thrusting) {
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

extension on Vector2 {
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

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Draggable;

import 'keyboard_routing.dart';
import 'logger.dart';

class MobileControllerRight extends HudMarginComponent<MobileControllerEvents> {
  static const _log = Logger('MobileControllerRight');

  MobileControllerRight()
      : super(
          margin: EdgeInsets.only(bottom: 50, right: 50),
          anchor: Anchor.bottomRight,
        );

  late final primary = _PrimaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.primary),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.primary),
    buttonColor: Colors.green,
    pressedButtonColor: Colors.lightGreen,
  );

  late final secondary1 = _SecondaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.secondary1),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.secondary1),
    text: 'D',
    position: 1,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary2 = _SecondaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.secondary2),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.secondary2),
    text: 'B',
    position: 2,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary3 = _SecondaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.secondary3),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.secondary3),
    text: 'C',
    position: 3,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary4 = _SecondaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.secondary4),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.secondary4),
    text: 'E',
    position: 4,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final tertiary1 = _TertiaryHudButtonComponent(
    onPressed: () => gameRef.onButtonDown(MobileControllerButton.tertiary1),
    onReleased: () => gameRef.onButtonUp(MobileControllerButton.tertiary1),
    text: 'F',
    position: 2,
    buttonColor: Colors.deepOrange.shade800,
    pressedButtonColor: Colors.orange,
  );

  @override
  Future<void> onLoad() async {
    await add(primary);
    await add(secondary1);
    await add(secondary2);
    await add(secondary3);
    await add(secondary4);
    await add(tertiary1);

    return super.onLoad();
  }
}

class _PrimaryHudButtonComponent extends HudButtonComponent {
  static const primaryButtonRadius = 40.0;

  _PrimaryHudButtonComponent({
    required VoidCallback onPressed,
    required VoidCallback onReleased,
    required Color buttonColor,
    required Color pressedButtonColor,
  }) : super(
          // TODO: find a way to actually center these
          anchor: Anchor(.85, .75),
          position: Vector2(0, -10),
          onPressed: onPressed,
          onReleased: onReleased,
          button: CircleComponent(
            radius: primaryButtonRadius,
            paint: Paint()..color = buttonColor,
          ),
          buttonDown: CircleComponent(
            radius: primaryButtonRadius,
            paint: Paint()..color = pressedButtonColor,
          ),
          children: [
            TextComponent(
              text: "A",
              textRenderer: TextPaint(
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              priority: 1,
              anchor: Anchor.center,
              position: Vector2(primaryButtonRadius, primaryButtonRadius),
            ),
          ],
        );
}

class _SecondaryHudButtonComponent extends HudButtonComponent {
  static const _buttonRadius = 25.0;
  static const _angularSpacing = 1 * pi / 4;

  _SecondaryHudButtonComponent({
    required VoidCallback onPressed,
    required VoidCallback onReleased,
    required int position,
    required String text,
    required Color buttonColor,
    required Color pressedButtonColor,
  }) : super(
          // TODO: find a way to actually center these
          anchor: Anchor(1.05, 1.08),
          onPressed: onPressed,
          onReleased: onReleased,
          position: Vector2.all(-65)
            ..rotate(position * _angularSpacing - 2.5 * _angularSpacing),
          button: CircleComponent(
            radius: _buttonRadius,
            paint: Paint()..color = buttonColor,
          ),
          buttonDown: CircleComponent(
            radius: _buttonRadius,
            paint: Paint()..color = pressedButtonColor,
          ),
          children: [
            TextComponent(
              text: text,
              textRenderer: TextPaint(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              priority: 1,
              anchor: Anchor.center,
              position: Vector2(_buttonRadius, _buttonRadius),
            ),
          ],
        );
}

class _TertiaryHudButtonComponent extends HudButtonComponent {
  static const _buttonRadius = 20.0;
  static const _angularSpacing = 1 * pi / 4;

  _TertiaryHudButtonComponent({
    required VoidCallback onPressed,
    required VoidCallback onReleased,
    required int position,
    required String text,
    required Color buttonColor,
    required Color pressedButtonColor,
  }) : super(
          // TODO: find a way to actually center these
          anchor: Anchor(1.2, 1.2),
          onPressed: onPressed,
          onReleased: onReleased,
          position: Vector2.all(-105)
            ..rotate(position * _angularSpacing - 2 * _angularSpacing),
          button: CircleComponent(
            radius: _buttonRadius,
            paint: Paint()..color = buttonColor,
          ),
          buttonDown: CircleComponent(
            radius: _buttonRadius,
            paint: Paint()..color = pressedButtonColor,
          ),
          children: [
            TextComponent(
              text: text,
              textRenderer: TextPaint(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              priority: 1,
              anchor: Anchor.center,
              position: Vector2(_buttonRadius, _buttonRadius),
            ),
          ],
        );
}

class MobileControllerLeft extends HudMarginComponent<MobileControllerEvents>
    with Draggable {
  static const defaultOpacity = 0.7;
  static final centerPoint = Vector2(110, 100);

  MobileControllerLeft()
      : super(
          margin: EdgeInsets.only(bottom: 1, left: 1),
        );

  late final startOffset = Vector2.zero();
  late final dragOffset = Vector2.zero();
  late final stickOffset = Vector2.zero();
  late final stickVector = Vector2.zero();

  late final cardinality = CircleComponent(
    radius: 110 / 2,
    paint: Paint()..color = Color.fromRGBO(30, 30, 30, defaultOpacity),
    anchor: Anchor.center,
  );

  late final stickBackground = CircleComponent(
    radius: 40 / 2,
    paint: Paint()..color = Color.fromRGBO(10, 10, 10, defaultOpacity),
    anchor: Anchor.center,
  );

  late final stick = CircleComponent(
    radius: 35 / 2,
    paint: Paint()..color = Color.fromRGBO(130, 130, 130, defaultOpacity),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await add(cardinality);
    await add(stickBackground);
    await add(stick);
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 _) {
    size.setFrom(Vector2(gameRef.canvasSize.x / 2, gameRef.canvasSize.y));
    super.onGameResize(_);
  }

  @override
  bool onDragStart(DragStartInfo info) {
    startOffset
      ..setFrom(info.eventPosition.viewport)
      ..x -= centerPoint.x
      ..y -= gameRef.canvasSize.y - centerPoint.x;
    cardinality.setOpacity(1.0);
    stickBackground.setOpacity(1.0);
    stick.setOpacity(1.0);
    return super.onDragStart(info);
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    final maxLength = cardinality.radius;
    dragOffset.add(info.delta.viewport);
    stickOffset
      ..setFrom(dragOffset)
      ..clampLength(maxLength);
    stickVector.setFrom(stickOffset / maxLength);
    gameRef.onStickChanged(stickVector);
    return super.onDragUpdate(info);
  }

  void _completeDrag() {
    cardinality.setOpacity(defaultOpacity);
    stickBackground.setOpacity(defaultOpacity);
    stick.setOpacity(defaultOpacity);
    startOffset.setZero();
    dragOffset.setZero();
    stickOffset.setZero();
    stickVector.setZero();
    gameRef.onStickChanged(Vector2.zero());
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    _completeDrag();
    return super.onDragEnd(info);
  }

  @override
  bool onDragCancel() {
    _completeDrag();
    return super.onDragCancel();
  }

  @override
  void update(double dt) {
    final baseOffset = Vector2(centerPoint.x, size.y - centerPoint.y);
    cardinality.position.setFrom(baseOffset + startOffset);
    stickBackground.position.setFrom(baseOffset + startOffset);
    stick.position.setFrom(baseOffset + startOffset + stickOffset);
    super.update(dt);
  }
}

extension MobileControllerVector2 on Vector2 {
  void clampLength(double maxLength) {
    if (this.length > maxLength) {
      normalize();
      scaleTo(maxLength);
    }
  }

  String toShortString() =>
      [x.toStringAsFixed(2), y.toStringAsFixed(2)].toString();

  AxisDirection? get stickDirection {
    if (length > 0.5) {
      final angle = screenAngle();

      const nw = -pi / 4;
      const ne = pi / 4;
      const se = 3 * pi / 4;
      const sw = -3 * pi / 4;

      if (angle > nw && angle <= ne) {
        return AxisDirection.up;
      } else if (angle > ne && angle <= se) {
        return AxisDirection.right;
      } else if (angle > se || angle <= sw) {
        return AxisDirection.down;
      } else {
        return AxisDirection.left;
      }
    }

    return null;
  }

  Set<AxisDirection> get stickDirectionWithDiagonal {
    if (length > 0.5) {
      final angle = screenAngle();

      const nne = 1 * pi / 8;
      const ene = 3 * pi / 8;
      const ese = 5 * pi / 8;
      const sse = 7 * pi / 8;
      const ssw = -7 * pi / 8;
      const wsw = -5 * pi / 8;
      const wnw = -3 * pi / 8;
      const nnw = -1 * pi / 8;

      if (angle > nnw && angle <= nne) {
        return {AxisDirection.up};
      } else if (angle > nne && angle <= ene) {
        return {AxisDirection.up, AxisDirection.right};
      } else if (angle > ene && angle <= ese) {
        return {AxisDirection.right};
      } else if (angle > ese && angle <= sse) {
        return {AxisDirection.right, AxisDirection.down};
      } else if (angle > sse || angle <= ssw) {
        return {AxisDirection.down};
      } else if (angle > ssw && angle <= wsw) {
        return {AxisDirection.down, AxisDirection.left};
      } else if (angle > wsw && angle <= wnw) {
        return {AxisDirection.left};
      } else {
        return {AxisDirection.left, AxisDirection.up};
      }
    }

    return const {};
  }
}

mixin MobileControllerEvents on FlameGame {
  void onStickChanged(Vector2 vector) {}

  void onButtonDown(MobileControllerButton button) {}

  void onButtonUp(MobileControllerButton button) {}
}

mixin MobileControllerRouting on MobileControllerEvents {
  @override
  void onStickChanged(Vector2 vector) {
    mobileControllerRouter.onStickChanged(vector);
    super.onStickChanged(vector);
  }

  @override
  void onButtonDown(MobileControllerButton button) {
    mobileControllerRouter.onButtonDown(button);
    super.onButtonDown(button);
  }

  @override
  void onButtonUp(MobileControllerButton button) {
    mobileControllerRouter.handleButtonUp(button);
    super.onButtonUp(button);
  }

  MobileControllerRouter get mobileControllerRouter;
}

class MobileControllerRouter {
  final Map<MobileControllerButton, ButtonRouter> handlePress;
  final void Function(Vector2 vector)? handleStickChanged;
  final Map<AxisDirection, ButtonRouter> handleStickDirection;
  final bool handleDiagonals;

  MobileControllerRouter({
    this.handlePress = const {},
    this.handleStickChanged,
    this.handleStickDirection = const {},
    this.handleDiagonals = false,
  });

  final _previousDirections = <AxisDirection>{};

  void onStickChanged(Vector2 vector) {
    handleStickChanged?.call(vector);

    final directions = handleDiagonals
        ? vector.stickDirectionWithDiagonal
        : vector.stickDirection == null
            ? const <AxisDirection>{}
            : {vector.stickDirection!};

    final stoppedDirections =
        _previousDirections.where((e) => !directions.contains(e));

    final newDirections =
        directions.where((e) => !_previousDirections.contains(e));

    for (final direction in stoppedDirections) {
      handleStickDirection[direction]?.onUp?.call();
    }

    for (final direction in newDirections) {
      handleStickDirection[direction]?.onDown();
    }

    _previousDirections
      ..clear()
      ..addAll(directions);
  }

  void onButtonDown(MobileControllerButton button) {
    handlePress[button]?.onDown.call();
  }

  void handleButtonUp(MobileControllerButton button) {
    handlePress[button]?.onUp?.call();
  }
}

enum MobileControllerButton {
  primary,
  secondary1,
  secondary2,
  secondary3,
  secondary4,
  tertiary1,
}

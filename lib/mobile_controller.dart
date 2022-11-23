import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

class MobileControllerRight extends HudMarginComponent {
  MobileControllerRight()
      : super(
          margin: EdgeInsets.only(bottom: 25, right: 25),
          anchor: Anchor.bottomRight,
        );
  static const _log = Logger('MobileControllerRight');

  static const primaryButtonRadius = 50.0;
  static const secondaryButtonRadius = 35.0;

  late final primaryButton = HudButtonComponent(
    anchor: Anchor.bottomRight,
    position: Vector2(0, -10),
    onPressed: () => _log.v('onPressed primary'),
    onReleased: () => _log.v('onReleased primary'),
    button: CircleComponent(
      radius: primaryButtonRadius,
      paint: Paint()..color = Colors.green,
    ),
    buttonDown: CircleComponent(
      radius: primaryButtonRadius,
      paint: Paint()..color = Colors.lightGreen,
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

  late final secondaryButton = HudButtonComponent(
    anchor: Anchor.bottomRight,
    onPressed: () => _log.v('onPressed secondary'),
    onReleased: () => _log.v('onReleased secondary'),
    position: Vector2(-100, -70),
    button: CircleComponent(
      radius: secondaryButtonRadius,
      paint: Paint()..color = Colors.blue,
    ),
    buttonDown: CircleComponent(
      radius: secondaryButtonRadius,
      paint: Paint()..color = Colors.lightBlue,
    ),
    children: [
      TextComponent(
        text: "B",
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        priority: 1,
        anchor: Anchor.center,
        position: Vector2(secondaryButtonRadius, secondaryButtonRadius),
      ),
    ],
  );

  @override
  Future<void> onLoad() async {
    await add(primaryButton);
    await add(secondaryButton);
    return super.onLoad();
  }
}

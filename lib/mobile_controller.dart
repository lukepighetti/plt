import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

class MobileControllerRight extends HudMarginComponent {
  static const _log = Logger('MobileControllerRight');

  MobileControllerRight()
      : super(
          margin: EdgeInsets.only(bottom: 50, right: 50),
          anchor: Anchor.bottomRight,
        );

  late final primary = _PrimaryHudButtonComponent(
    onPressed: () => _log.v('onPressed primary'),
    onReleased: () => _log.v('onReleased primary'),
    buttonColor: Colors.green,
    pressedButtonColor: Colors.lightGreen,
  );

  late final secondary1 = _SecondaryHudButtonComponent(
    onPressed: () => _log.v('onPressed B'),
    onReleased: () => _log.v('onReleased B'),
    text: 'D',
    position: 1,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary2 = _SecondaryHudButtonComponent(
    onPressed: () => _log.v('onPressed C'),
    onReleased: () => _log.v('onReleased C'),
    text: 'B',
    position: 2,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary3 = _SecondaryHudButtonComponent(
    onPressed: () => _log.v('onPressed D'),
    onReleased: () => _log.v('onReleased D'),
    text: 'C',
    position: 3,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final secondary4 = _SecondaryHudButtonComponent(
    onPressed: () => _log.v('onPressed E'),
    onReleased: () => _log.v('onReleased E'),
    text: 'E',
    position: 4,
    buttonColor: Colors.blue,
    pressedButtonColor: Colors.lightBlue,
  );

  late final tertiary1 = _TertiaryHudButtonComponent(
    onPressed: () => _log.v('onPressed E'),
    onReleased: () => _log.v('onReleased E'),
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

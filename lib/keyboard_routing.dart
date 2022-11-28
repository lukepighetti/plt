import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'logger.dart';

mixin KeyboardRouting on KeyboardEvents {
  @override
  KeyEventResult onKeyEvent(event, keysPressed) =>
      keyboardRouter.handleKeyEvent(event, keysPressed);

  KeyboardRouter get keyboardRouter;
}

class KeyboardRouter {
  static const _log = Logger('KeyboardRouter');

  final Map<LogicalKeyboardKey, LogicalKeyboardKey> keyAliases;
  final Map<LogicalKeyboardKey, Function> handleTap;
  final Map<LogicalKeyboardKey, ButtonRouter> handlePress;

  KeyboardRouter({
    this.keyAliases = const {},
    this.handleTap = const {},
    this.handlePress = const {},
  });

  KeyEventResult handleKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.repeat) return KeyEventResult.ignored;
    final alias = keyAliases[event.logicalKey];
    var didCall = false;
    if (event is RawKeyDownEvent) {
      final tapAction = handleTap[event.logicalKey] ?? handleTap[alias];
      if (tapAction != null) {
        _log.v('TAP  ${event.logicalKey.debugName}');
        didCall = true;
        tapAction();
      }
      final pressAction = handlePress[event.logicalKey] ?? handlePress[alias];
      if (pressAction != null) {
        _log.v('DOWN ${event.logicalKey.debugName}');
        didCall = true;
        pressAction.onDown();
      }
    } else if (event is RawKeyUpEvent) {
      final tapAction = handlePress[event.logicalKey] ?? handlePress[alias];
      if (tapAction?.onUp != null) {
        _log.v('UP   ${event.logicalKey.debugName}');
        didCall = true;
        tapAction!.onUp!.call();
      }
    }
    if (didCall)
      return KeyEventResult.handled;
    else
      return KeyEventResult.ignored;
  }
}

class ButtonRouter {
  final Function onDown;
  final Function? onUp;

  ButtonRouter({
    required this.onDown,
    this.onUp,
  });
}

class JoystickButtonValue {
  var buttonValue = false;
  var joystickValue = 0.0;

  double get value => ((buttonValue ? 1 : 0) + joystickValue).clamp(0.0, 1.0);

  void setZero() {
    buttonValue = false;
    joystickValue = 0.0;
  }
}

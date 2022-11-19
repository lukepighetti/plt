import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

mixin KeyboardRouting on KeyboardEvents {
  @override
  KeyEventResult onKeyEvent(event, keysPressed) =>
      keyboardRouter.handleKeyEvent(event, keysPressed);

  KeyboardRouter get keyboardRouter;
}

class KeyboardRouter {
  final Map<LogicalKeyboardKey, Function> handleTap;
  final Map<LogicalKeyboardKey, PressRouter> handlePress;
  final bool debug;

  KeyboardRouter(this.handleTap, this.handlePress, {this.debug = kDebugMode});

  KeyEventResult handleKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.repeat) return KeyEventResult.ignored;

    if (event is RawKeyDownEvent) {
      var didCall = false;
      final tapAction = handleTap[event.logicalKey];

      if (tapAction != null) {
        print('[KeyboardRouter] TAP ${event.logicalKey.debugName}');
        didCall = true;
        tapAction();
      }
      for (final key in keysPressed) {
        final pressAction = handlePress[key];
        if (pressAction != null) {
          print('[KeyboardRouter] DOWN ${key.debugName}');
          didCall = true;
          pressAction.onDown();
        }
      }
      if (didCall) return KeyEventResult.handled;
    } else if (event is RawKeyUpEvent) {
      var didCall = false;
      final tapAction = handlePress[event.logicalKey];
      if (tapAction != null) {
        print('[KeyboardRouter] UP ${event.logicalKey.debugName}');
        didCall = true;
        tapAction.onUp();
      }
      if (didCall) return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class PressRouter {
  final Function onDown;
  final Function onUp;

  PressRouter({
    required this.onDown,
    required this.onUp,
  });
}

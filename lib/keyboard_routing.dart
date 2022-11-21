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
  final Map<LogicalKeyboardKey, KeyRouter> handlePress;

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
    if (event is RawKeyDownEvent) {
      var didCall = false;
      final tapAction = handleTap[event.logicalKey] ?? handleTap[alias];

      if (tapAction != null) {
        _log.v('TAP  ${event.logicalKey.debugName}');
        didCall = true;
        tapAction();
      }
      for (final key in keysPressed) {
        final alias = keyAliases[key];
        final pressAction = handlePress[key] ?? handlePress[alias];
        if (pressAction != null) {
          _log.v('DOWN ${key.debugName}');
          didCall = true;
          pressAction.onDown();
        }
      }
      if (didCall) return KeyEventResult.handled;
    } else if (event is RawKeyUpEvent) {
      var didCall = false;
      final tapAction = handlePress[event.logicalKey] ?? handlePress[alias];
      if (tapAction?.onUp != null) {
        _log.v('UP   ${event.logicalKey.debugName}');
        didCall = true;
        tapAction!.onUp!.call();
      }
      if (didCall) return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class KeyRouter {
  final Function onDown;
  final Function? onUp;

  KeyRouter({
    required this.onDown,
    this.onUp,
  });
}

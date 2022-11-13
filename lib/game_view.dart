import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game_view_utils.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final game = MyGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}

class MyGame extends FlameGame with SingleGameInstance {
  late final Game game = findGame()!;

  final me = MyCharacter();
  final horizon = MyHorizon();
  late final platforms = PositionComponent(
    position: Vector2(0, game.size.y),
    children: [
      MyPlatform(Vector2(050, -250)),
      MyPlatform(Vector2(150, -450)),
      MyPlatform(Vector2(250, -650)),
    ],
  );

  @override
  Future<void> onLoad() async {
    await add(me);
    await add(horizon);
    await add(platforms);
    await add(FpsTextComponent());

    me.position = Vector2(150, game.size.y - 150);
    horizon.position = Vector2(0, game.size.y - horizon.size.y);
  }
}

class MyCharacter extends PlaceholderComponent {
  @override
  Future<void> onLoad() async {
    size = Vector2(50, 50);
    color = Colors.red;
  }
}

class MyHorizon extends PlaceholderComponent {
  @override
  Future<void> onLoad() async {
    size = Vector2(findGame()!.size.x, 50);
    color = Colors.green;
  }
}

class MyPlatform extends PlaceholderComponent {
  MyPlatform(this.offset);

  final Vector2 offset;

  @override
  Future<void> onLoad() async {
    size = Vector2(250, 25);
    position = offset;
    color = Colors.orange;
  }
}

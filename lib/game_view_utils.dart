import 'package:flame_forge2d/flame_forge2d.dart';

extension PolygonShapeX on PolygonShape {
  void setAsBoxFromSize(Vector2 size) {
    setAsBox(
      size.x / 2,
      size.y / 2,
      Vector2(size.x / 2, size.y / 2),
      0,
    );
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

mixin CollisionRouting on CollisionCallbacks {
  CollisionRouter get collisionRouter;

  @override
  void onCollisionStart(_, PositionComponent other) {
    collisionRouter.handleType[other.runtimeType]?.onStart?.call(other);
    super.onCollisionStart(_, other);
  }

  @override
  void onCollision(_, PositionComponent other) {
    collisionRouter.handleType[other.runtimeType]?.onFrame?.call(other);
    super.onCollision(_, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    collisionRouter.handleType[other.runtimeType]?.onEnd?.call(other);
    super.onCollisionEnd(other);
  }
}

class CollisionRouter {
  final Map<Type, CollideRouter> handleType;

  CollisionRouter({this.handleType = const {}});
}

class CollideRouter {
  final void Function(PositionComponent)? onStart;
  final void Function(PositionComponent)? onFrame;
  final void Function(PositionComponent)? onEnd;

  CollideRouter({
    this.onStart,
    this.onFrame,
    this.onEnd,
  });
}

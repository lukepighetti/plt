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

/// A simple FIFO queue
class FifoQueue<T> {
  final _list = <T>[];
  void add(T value) => _list.add(value);
  void addAll(Iterable<T> values) => _list.addAll(values);
  T pop() => _list.removeLast();
  List<T> popAll() {
    final newList = List<T>.from(_list);
    _list.clear();
    return newList;
  }

  void clear() => _list.clear();
  bool get hasItems => _list.isNotEmpty;
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

// A flame component that has a color associated with it
class PlaceholderComponent extends CustomPainterComponent {
  var color = Colors.red;

  @override
  late final painter = _ColoredPainter(color);
}

class _ColoredPainter extends CustomPainter {
  _ColoredPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ColoredPainter old) => old.color != color;
}

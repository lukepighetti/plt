import 'package:flutter/foundation.dart';

class Logger {
  static const minLevel = 5;

  final String namespace;

  const Logger(this.namespace);

  void e(String message) => _log('E', 1, message);
  void i(String message) => _log('I', 3, message);
  void v(String message) => _log('V', 5, message);

  void _log(String prefix, int level, String message) {
    if (level <= minLevel) debugPrint('$prefix [$namespace] $message');
  }
}

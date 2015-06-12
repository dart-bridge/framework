part of bridge.exceptions;

class BaseException implements Exception, Serializable {
  final String message;

  BaseException([String this.message]);

  String toString() {
    final String name = this.runtimeType.toString();
    if (message != null) return '$name: $message';
    return name;
  }

  Object serialize() {
    return toString();
  }
}
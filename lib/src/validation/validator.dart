part of bridge.validation.shared;

abstract class Validator {
  factory Validator() => new _Validator();

  void validate(Map<String, dynamic> values, Map<String, Guard> guards);
}

class _Validator implements Validator {
  void validate(Map<String, dynamic> values, Map<String, Guard> guards) {
    for (final key in guards.keys)
      _validate(key, values[key], guards[key]);
  }

  void _validate(String key, value, Guard guard) {
    final message = guard(key, value);
    if (message != null)
      throw new ValidationException(message);
  }
}

typedef String Guard(String key, value);

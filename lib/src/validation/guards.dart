part of bridge.validation.shared;

class Guards {
  static String required(String key, value) {
    if (value == null || value == '' || (value is Iterable && value.isEmpty))
      return '$key is a required field';
    return null;
  }

  static String numeric(String key, value) {
    if (value == null) return null;
    if (!(value is num || new RegExp(r'^\d*\.?\d+$').hasMatch(value)))
      return '$key must be numeric';
    return null;
  }

  static Guard catches(callback(String key, value)) {
    return (String key, value) {
      if (value == null) return null;
      try {
        callback(key, value);
      } catch(e) {
        return '$e';
      }
    };
  }

  static Guard all(List<Guard> guards) {
    return (String key, value) {
      for (final guard in guards) {
        final message = guard(key, value);
        if (message != null)
          return message;
      }
    };
  }

  static Guard matches(String regex,
      {bool multiLine: false,
      bool caseSensitive: true}) {
    return (String key, value) {
      if (!new RegExp(regex,
          multiLine: multiLine,
          caseSensitive: caseSensitive)
          .hasMatch('$value'))
        return '$key doesn\'t match $regex, got "$value"';
    };
  }

  static Guard get email => matches(r'@.+\..+');
}

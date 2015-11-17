library bridge.http.sessions.session;
import 'dart:math' show Random;

class Session {
  final Map<String, dynamic> variables = {};
  final Map<String, dynamic> _flashedSessionVariables = {};
  final List<String> _reflashedKeys = [];
  final String id;
  bool isNew = false;

  Session(String this.id);

  factory Session.generate() {
    var out = '';
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = new Random();
    for (var i = 0; i < 128; ++i)
      out += chars[random.nextInt(chars.length - 1)];
    return new Session(out);
  }

  Object get(String key) {
    if (_flashedSessionVariables.containsKey(key))
      return _flashedSessionVariables[key];
    return variables[key];
  }

  void set(String key, value) {
    variables[key] = value;
  }

  operator [](String key) => get(key);
  operator []=(String key, value) => set(key, value);

  void flash(String key, value) {
    _flashedSessionVariables[key] = value;
    reflash(key);
  }

  void clearOldFlashes() {
    for (var key in _flashedSessionVariables.keys.toList()) {
      if (_reflashedKeys.contains(key)) continue;
      _flashedSessionVariables.remove(key);
    }
    _reflashedKeys.clear();
  }

  void reflash(String key) {
    if (!_reflashedKeys.contains(key))
      _reflashedKeys.add(key);
  }

  void apply(Session session) {
    if (session.id != id)
      throw new ArgumentError('Applied Session must have the same id');
    variables.addAll(session.variables);
    _flashedSessionVariables.addAll(session._flashedSessionVariables);
    for (final key in session._reflashedKeys)
        if (!_reflashedKeys.contains(key))
          _reflashedKeys.add(key);
  }

  String toString() {
    return 'Session(${new Map.from(_flashedSessionVariables)..addAll(variables)})';
  }
}

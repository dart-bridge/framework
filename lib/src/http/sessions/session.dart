library bridge.http.sessions.session;

import 'package:tether/protocol.dart' as tether;

class Session implements tether.Session {
  final Map<String, dynamic> _variables = {};
  final Map<String, dynamic> _flashedSessionVariables = {};
  final List<String> _reflashedKeys = [];
  final String id;
  bool isNew = false;

  Session(String this.id);

  Object get(String key) {
    if (_flashedSessionVariables.containsKey(key))
      return _flashedSessionVariables[key];
    return _variables[key];
  }

  void set(String key, value) {
    _variables[key] = value;
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
    _variables.addAll(session._variables);
    _flashedSessionVariables.addAll(session._flashedSessionVariables);
    for (final key in session._reflashedKeys)
        if (!_reflashedKeys.contains(key))
          _reflashedKeys.add(key);
  }

  String toString() {
    return 'Session(${new Map.from(_flashedSessionVariables)..addAll(_variables)})';
  }

  Map get data => _variables;
}

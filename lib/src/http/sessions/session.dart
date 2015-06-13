part of bridge.http.sessions;

class Session {
  final Map<String, dynamic> _sessionVariables = {};
  final Map<String, dynamic> _flashedSessionVariables = {};
  final List<String> _reflashedKeys = [];
  final String id;
  bool isNew = false;

  Session(String this.id);

  Object get(String key) {
    if (_flashedSessionVariables.containsKey(key))
      return _flashedSessionVariables[key];
    return _sessionVariables[key];
  }

  void set(String key, value) {
    _sessionVariables[key] = value;
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
}

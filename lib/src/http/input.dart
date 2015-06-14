part of bridge.http;

class Input extends MapBase<String, dynamic> {
  Map<String, dynamic> _data;

  Input(Map<String, dynamic> this._data);

  toString() {
    return 'Input(${_data.toString()})';
  }

  operator [](Object key) => _data[key];

  operator []=(String key, value) => _data[key] = value;

  void clear() => _data.clear();

  Iterable<String> get keys => _data.keys;

  remove(Object key) => _data.remove(key);
}

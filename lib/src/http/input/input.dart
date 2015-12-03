part of bridge.http;

abstract class Input<T> implements Map<String, T> {
  factory Input(Map<String, T> data) => new _Input(data);

  T get(String key, [defaultValue]);

  bool has(String key);

  Map<String, T> toMap();

  Input<UploadedFile> get files;

  Input<T> only(List<String> keys);
}

abstract class InputBase<T> extends MapBase<String, T> implements Input<T> {
  Input<UploadedFile> get files {
    final filesMap = <String, UploadedFile>{};
    forEach((key, value) {
      if (value is UploadedFile) filesMap[key] = value;
    });
    return new Input<UploadedFile>(filesMap);
  }

  Input<T> only(List<String> keys) {
    final newMap = <String, T>{};
    forEach((key, value) {
      if (keys.contains(key)) newMap[key] = value;
    });
    return new Input<T>(newMap);
  }

  toString() {
    return 'Input(${toMap().toString()})';
  }

  // Implementing `Map`
  @override
  operator [](String key) => get(key);

  @override
  operator []=(String key, value) {
    throw new UnsupportedError('The Input object is immutable');
  }

  @override
  void clear() {
    throw new UnsupportedError('The Input object is immutable');
  }

  @override
  remove(Object key) {
    throw new UnsupportedError('The Input object is immutable');
  }
}

class _Input<T> extends InputBase<T> {
  Map<String, T> _data;

  _Input(this._data);

  @override
  T get(String key, [defaultValue]) => _data[key] ?? defaultValue;

  @override
  bool has(String key) => _data.containsKey(key);

  @override
  Iterable<String> get keys => _data.keys;

  @override
  Map<String, T> toMap() => new Map.from(_data);
}
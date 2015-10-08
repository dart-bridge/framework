part of bridge.http;

class Input<T> extends MapBase<String, T> implements Map<String, T> {
  Map<String, T> _data;

  Input(this._data);

  toString() {
    return 'Input(${_data.toString()})';
  }

  T get(String key, [defaultValue]) => _data[key] ?? defaultValue;

  bool has(String key) => _data.containsKey(key);

  Map<String, dynamic> toMap() => new Map.from(_data);

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

  // Implementing `Map`
  @override
  operator [](String key) => get(key);

  @override
  Iterable<String> get keys => _data.keys;

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

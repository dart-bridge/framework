part of bridge.transport.shared;

typedef Object SerializationTransform(Object object);

abstract class Serializer {
  static final Serializer instance = new Serializer();

  factory Serializer() => new _Serializer();

  Object serialize(Object object, {bool flatten: false});

  Object deserialize(Object serialized);

  void register(String id,
      Type type,
      {SerializationTransform serialize: _defaultTransform,
      SerializationTransform deserialize: _defaultTransform});

  static Object _defaultTransform(Object object) {
    return object.toString();
  }
}

class _Serializer implements Serializer {
  final Map<Type, String> _types = {};
  final Map<Type, SerializationTransform> _serializers = {};
  final Map<String, SerializationTransform> _deserializers = {};

  Object serialize(Object object, {bool flatten: false}) {
    if ([String, int, double, bool, Null].contains(object.runtimeType))
      return object;
    if (object is List) return _transformList(
        object, (_) => serialize(_, flatten: flatten));
    if (object is Map) return _transformMap(
        object, (_) => serialize(_, flatten: flatten));
    if (_serializers.containsKey(object.runtimeType))
      return _serializeRegistered(object, flatten);
    return object.toString();
  }

  Object _serializeRegistered(Object object, bool flatten) {
    final serialized = _serializers[object.runtimeType](object);
    if (flatten) return serialize(serialized, flatten: flatten);
    return serialize({
      r'$$': _types[object.runtimeType],
      r'$$$': serialized,
    }, flatten: flatten);
  }

  Object _transformList(List list, SerializationTransform transform) {
    return list.map(transform).toList();
  }

  Object _transformMap(Map map, SerializationTransform transform) {
    return new Map.fromIterables(map.keys, map.values.map(transform));
  }

  Object deserialize(Object serialized) {
    if (_isSerializedStructure(serialized))
      return _deserializeRegistered(serialized);
    if (serialized is List) return _transformList(serialized, deserialize);
    if (serialized is Map) return _transformMap(serialized, deserialize);
    return serialized;
  }

  bool _isSerializedStructure(Object serialized) {
    return serialized is Map
        && serialized.containsKey(r'$$')
        && serialized.containsKey(r'$$$');
  }

  Object _deserializeRegistered(Map serialized) {
    final id = serialized[r'$$'];
    final deserializer = _deserializers[id];
    if (deserializer == null)
      throw new SerializationException(id);
    return deserializer(deserialize(serialized[r'$$$']));
  }

  void register(String id, Type type,
      {SerializationTransform serialize: Serializer._defaultTransform,
      SerializationTransform deserialize: Serializer._defaultTransform}) {
    _types[type] = id;
    _serializers[type] = serialize;
    _deserializers[id] = deserialize;
  }
}

class SerializationException implements Exception {
  final String id;

  SerializationException(String this.id);

  String toString() => 'Structure [$id] is not registered.';
}

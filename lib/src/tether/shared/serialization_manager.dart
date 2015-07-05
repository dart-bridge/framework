part of bridge.tether.shared;

abstract class SerializationManager {
  factory SerializationManager() => new _SerializationManager();

  Object serialize(Object object);

  Object deserialize(Object serialized);

  void registerStructure(String id, Type serializable, SerializableFactory factory);
}

typedef Serializable SerializableFactory(serialized);

class _SerializationManager implements SerializationManager {
  final Map<String, dynamic> _structures = {};
  static final _structureIdentifier = '__STRUCTURE';

  Object serialize(Object object) {
    if (_isARegisteredStructure(object))
      return _toStructureTuplet(object);
    return _cast(_treatMapAndListValues(object, serialize));
  }

  Object _cast(object) {
    if (object is num
    || object is bool
    || object is String
    || object == null
    || object is List
    || object is Map<String, dynamic>)
      return object;
    if (object is Serializable) return object.serialize();
    try {
      return object.toJson();
    } on NoSuchMethodError {
      return object.toString();
    }
  }

  Object _treatMapAndListValues(object, treat(object)) {
    if (object is Map) return new Map.fromIterables(object.keys, object.values.map(treat));
    if (object is List) return object.map(treat).toList();
    return object;
  }

  bool _isARegisteredStructure(Object object) {
    return _structures.keys.any(
            (type) => object.runtimeType.toString() == type
    ) && object is Serializable;
  }

  Object _toStructureTuplet(Serializable object) {
    return [_structureIdentifier, _structures[object.runtimeType.toString()][0], object.serialize()];
  }

  Object deserialize(serialized) {
    if (_isStructureTuplet(serialized)) {
      var factory = _getFactoryFromTuplet(serialized);
      return factory(_getSerializedDataFromTuplet(serialized));
    }
    return _treatMapAndListValues(serialized, deserialize);
  }

  bool _isStructureTuplet(serialized) {
    return serialized is List && serialized.length > 0 && serialized[0] == _structureIdentifier;
  }

  SerializableFactory _getFactoryFromTuplet(List tuplet) {
    return _structures.values.firstWhere((s) => s[0] == tuplet[1])[1];
  }

  _getSerializedDataFromTuplet(serialized) {
    return serialized[2];
  }

  void registerStructure(String id, Type serializable, SerializableFactory factory) {
    _structures[serializable.toString()] = [id, factory];
  }
}

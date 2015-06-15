part of bridge.database.mongodb;

class MongoCollection implements Collection {
  MongoSelector get select => new MongoSelector(this);
  mongo.DbCollection _collection;

  MongoCollection(mongo.DbCollection this._collection);

  Future<List> all() {
    return _collection.find().toList().then((m) => m.map(_fieldToStringId));
  }

  Future find(id) async {
    return _collection.findOne(_whereId(id)._builder).then(_fieldToStringId);
  }

  Future first(MongoSelector query) {
    return _collection.findOne(query._builder).then(_fieldToStringId);
  }

  Future<List> get(MongoSelector query) {
    return _collection.find(query._builder).toList().then((m) => m.map(_fieldToStringId));
  }

  Future save(data) async {
    if (data['id'] == null) data['id'] = _generateId();
    await _collection.save(_fieldToObjectId(data));
    return data['id'];
  }

  String _generateId() {
    return new mongo.ObjectId().toHexString();
  }

  Map _fieldToObjectId(Map map) {
    map = new Map.from(map);
    map['_id'] = _toObjectId(map['id']);
    map.remove('id');
    return map;
  }

  Map _fieldToStringId(Map map) {
    if (map == null) return {};
    map = new Map.from(map);
    map['id'] = _toStringId(map['_id']);
    map.remove('_id');
    return map;
  }

  String _toStringId(mongo.ObjectId id) {
    return id.toHexString();
  }

  mongo.ObjectId _toObjectId(String id) {
    return mongo.ObjectId.parse(id);
  }

  MongoSelector _whereId(String id) {
    return select.where('_id', isEqualTo: _toObjectId(id));
  }

  MongoSelector where(String field,
                      {isEqualTo,
                      isNotEqualTo,
                      isLessThan,
                      isGreaterThan,
                      isLessThanOrEqualTo,
                      isGreaterThanOrEqualTo}) {
    return select.where(
        field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isGreaterThan: isGreaterThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
  }

  Future delete(Map data) async {
    await _collection.remove(_whereId(data['id'])._builder);
  }
}

part of bridge.database.mongodb;

class MongoCollection implements Collection {
  MongoSelector select;
  mongo.DbCollection _collection;

  MongoCollection(mongo.DbCollection this._collection) {
    select = new MongoSelector(this);
  }

  Map _setIdWithoutUnderscore(Map input) {
    input['id'] = input['_id'];
    input.remove('_id');
    return input;
  }

  Map _setIdWithUnderscore(Map input) {
    input = {}..addAll(input);
    input['_id'] = input['id'];
    input.remove('id');
    return input;
  }

  List<Map> _setEachIdWithoutUnderscore(List<Map> inputs) {
    return inputs.map(_setIdWithoutUnderscore).toList();
  }

  Future<List> all() {
    return _collection.find().toList().then(_setEachIdWithoutUnderscore);
  }

  Future find(id) async {
    return _collection.findOne(mongo.where.id(id)).then(_setIdWithoutUnderscore);
  }

  Future<List> get(MongoSelector query) async {
    return _collection.find(query._builder).toList().then(_setEachIdWithoutUnderscore);
  }

  Future first(MongoSelector query) {
    return _collection.findOne(query._builder).then(_setIdWithoutUnderscore);
  }

  MongoSelector where(String field, Is comparison, value) {
    return select.where(field, comparison, value);
  }

  Future save(data) async {
    if (data['id'] == null)
      data['id'] = new mongo.ObjectId();
    await _collection.save(_setIdWithUnderscore(data));
    return data['id'];
  }
}

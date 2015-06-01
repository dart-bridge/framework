part of bridge.database.mongodb;

class MongoCollection implements Collection {
  MongoSelector select;
  mongo.DbCollection _collection;

  MongoCollection(mongo.DbCollection this._collection) {
    select = new MongoSelector(this);
  }

  Future<List> all() {
    return _collection.find().toList();
  }

  Future find(id) {
    return _collection.findOne(mongo.where.id(id));
  }

  Future<List> get(MongoSelector query) {
    return _collection.find(query._builder).toList();
  }

  Future first(MongoSelector query) {
    return _collection.findOne(query._builder);
  }

  MongoSelector where(String field, Is comparison, value) {
    return select.where(field, comparison, value);
  }
}

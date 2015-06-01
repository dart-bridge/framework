part of bridge.database.mongodb;

class MongoSelector implements Selector {
  mongo.SelectorBuilder _builder = mongo.where;
  MongoCollection _collection;

  MongoSelector(MongoCollection _collection);

  Future<List> every(String field) {
    return fields([field]);
  }

  Future<List> fields(List<String> fields) {
    return _collection._collection.find(_builder.fields(fields)).toList();
  }

  Future first() {
    return _collection._collection.findOne(_builder);
  }

  Future<List> get() {
    return _collection._collection.find(_builder).toList();
  }

  Selector where(String field, Is comparison, value) {
    switch (comparison) {
      case Is.equalTo:
        _builder = _builder.eq(field, value);
        break;
      case Is.notEqualTo:
        _builder = _builder.ne(field, value);
        break;
      case Is.lessThan:
        _builder = _builder.lt(field, value);
        break;
      case Is.lessThanOrEqualTo:
        _builder = _builder.lte(field, value);
        break;
      case Is.greaterThan:
        _builder = _builder.gt(field, value);
        break;
      case Is.greaterThanOrEqualTo:
        _builder = _builder.gte(field, value);
        break;
    }
    return this;
  }
}

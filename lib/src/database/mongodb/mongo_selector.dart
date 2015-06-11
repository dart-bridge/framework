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

  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo}) {
    var has = (v) => v != null;
    if (has(isEqualTo))
      _builder = _builder.eq(field, isEqualTo);
    if (has(isNotEqualTo))
      _builder = _builder.ne(field, isNotEqualTo);
    if (has(isLessThan))
      _builder = _builder.lt(field, isLessThan);
    if (has(isLessThanOrEqualTo))
      _builder = _builder.lte(field, isLessThanOrEqualTo);
    if (has(isGreaterThan))
      _builder = _builder.gt(field, isGreaterThan);
    if (has(isGreaterThanOrEqualTo))
      _builder = _builder.gte(field, isGreaterThanOrEqualTo);
    return this;
  }
}

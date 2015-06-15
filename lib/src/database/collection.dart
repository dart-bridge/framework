part of bridge.database;

abstract class Collection {
  Selector get select;

  Future<List> all();

  Future find(id);

  Future<List> get(Selector query);

  Future first(Selector query);

  Future save(data);

  Future delete(data);

  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo});
}

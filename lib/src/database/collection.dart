part of bridge.database;

abstract class Collection {
  Selector select;

  Future<List> all();

  Future find(id);

  Future<List> get(Selector query);

  Future first(Selector query);

  Future save(data);

  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo});
}

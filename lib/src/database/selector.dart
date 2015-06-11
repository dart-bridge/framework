part of bridge.database;

abstract class Selector {
  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo});

  Future<List> get();

  Future first();

  Future<List> every(String field);

  Future<List> fields(List<String> fields);
}

part of bridge.database;

abstract class Selector {
  Selector where(String field, Is comparison, value);

  Future<List> get();

  Future first();

  Future<List> every(String field);

  Future<List> fields(List<String> fields);
}

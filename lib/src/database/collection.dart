part of bridge.database;

abstract class Collection {
  Selector select;

  Future<List> all();

  Future find(id);

  Future<List> get(Selector query);

  Future first(Selector query);

  Selector where(String field, Is comparison, value);
}

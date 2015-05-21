part of bridge.database;

abstract class RepositoryInterface<M> {

  Future<List<M>> all();

  Future<List<M>> find(ObjectoryQueryBuilder query);

  Future add(M model);
}

var _where = where;

abstract class Repository<M> implements RepositoryInterface<M> {

  ObjectoryQueryBuilder get where => _where;

  ObjectoryCollection get _collection => objectory[M];

  Future<List<M>> all() {

    return _collection.find();
  }

  Future<List<M>> find(ObjectoryQueryBuilder query) =>
  _collection.find(query);

  Future add(M model) => model.save();
}
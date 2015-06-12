part of bridge.database.in_memory;

class InMemorySelector implements Selector {
  final Map<String, List> _constraints = {};
  final InMemoryCollection _collection;

  InMemorySelector(InMemoryCollection this._collection);

  Future<List> every(String field) async {
    return (await fields([field])).map((m) => m[field]);
  }

  Future<List> fields(List<String> fields) async {
    Iterable matches = await _collection.get(this);
    return matches.map((Map m) => fields.map((f) => m[f])).toList();
  }

  Future first() async {
    Iterable matches = await _collection.get(this);
    return matches.first;
  }

  Future<List> get() async {
    return _collection.get(this);
  }

  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo}) {
    if (isEqualTo != null)
    _constraints[field] = ['==', isEqualTo];
    if (isNotEqualTo != null)
    _constraints[field] = ['!=', isNotEqualTo];
    if (isLessThan != null)
    _constraints[field] = ['<', isLessThan];
    if (isGreaterThan != null)
    _constraints[field] = ['>', isGreaterThan];
    if (isLessThanOrEqualTo != null)
    _constraints[field] = ['<=', isLessThanOrEqualTo];
    if (isGreaterThanOrEqualTo != null)
    _constraints[field] = ['>=', isGreaterThanOrEqualTo];
    return this;
  }
}

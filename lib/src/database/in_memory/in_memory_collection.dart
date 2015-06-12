part of bridge.database.in_memory;

class InMemoryCollection implements Collection {
  InMemorySelector select;
  final List _rows = [];

  InMemoryCollection() {
    this.select = new InMemorySelector(this);
  }

  Future<List> all() async {
    return _rows;
  }

  Future find(id) {
    return where('id', isEqualTo: id).first();
  }

  Future first(InMemorySelector query) async {
    return _rows.where((e) => _matchesConstraints(e, query)).first;
  }

  Future<List> get(InMemorySelector query) async {
    return _rows.where((e) => _matchesConstraints(e, query)).toList();
  }

  Future save(data) async {
    if (data['id'] != null)
      _rows.removeWhere((m) => m['id'] == data['id']);
    _rows.add(data);
  }

  InMemorySelector where(String field,
                         {isEqualTo,
                         isNotEqualTo,
                         isLessThan,
                         isGreaterThan,
                         isLessThanOrEqualTo,
                         isGreaterThanOrEqualTo}) {
    return select.where(
        field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isGreaterThan: isGreaterThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
  }

  bool _matchesConstraints(Map element, InMemorySelector query) {
    if (query._constraints.isEmpty) return true;
    return element.keys.map((field) {
      if (!_hasConstraint(field, query)) return true;
      return _fieldMatchesConstraint(field, element[field], query);
    }).every((v) => v);
  }

  bool _hasConstraint(field, InMemorySelector query) {
    return query._constraints.containsKey(field);
  }

  bool _fieldMatchesConstraint(field, value, InMemorySelector query) {
    var constraintOperator = query._constraints[field][0];
    var constraintComparator = query._constraints[field][1];
    if (constraintOperator == '==')
      return value == constraintComparator;
    if (constraintOperator == '!=')
      return value != constraintComparator;
    if (constraintOperator == '<')
      return value < constraintComparator;
    if (constraintOperator == '>')
      return value > constraintComparator;
    if (constraintOperator == '<=')
      return value <= constraintComparator;
    if (constraintOperator == '>=')
      return value >= constraintComparator;
    return false;
  }
}

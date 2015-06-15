part of bridge.validation.shared;

class Validator {
  final Map<String, ValidationFilter> _filters = {
    'required': (input) {
      if (input == null
      || input == ''
      || input == false)
        return 'is required';
    },
  };

  void registerFilter(String name, ValidationFilter filter) {
    _filters[name] = filter;
  }

  Future validate(value, String expression) async {
    for (var filter in expression.split(',').map((s) => s.trim())) {
      _ensureCanValidate(value, filter);
      await _runFilter(value, filter);
    }
  }

  Future validateMany(List values, String expression) {
    return Future.wait(values.map((v) => validate(v, expression)));
  }

  bool _isIdenticalStringLists(Iterable<String> list1, Iterable<String> list2) {
    return list1.length == list2.length
    && list1.join('') == list2.join('');
  }

  Future validateAll(Map<String, dynamic> values,
                     Map<String, String> expressions) async {
    if (!_isIdenticalStringLists(values.keys, expressions.keys))
      throw new InvalidArgumentException('The lists of keys must be identical');
    var validations = <Future>[];
    values.forEach((k, v) {
      validations.add(validate(v, expressions[k]));
    });
    return Future.wait(validations);
  }

  void _ensureCanValidate(value, String filter) {
    if (!_hasFilter(filter))
      throw new InvalidArgumentException('$filter is not a registered filter');
  }

  bool _hasFilter(String name) {
    return _filters.containsKey(name);
  }

  Future _runFilter(value, String filter) async {
    var result = await _filters[filter](value);
    if (result != null) throw new ValidationException(result);
  }
}

typedef Future<String> ValidationFilter(value);

part of bridge.validation;

abstract class InputValidator<T> extends InputBase<T> {
  Input<T> _input;

  $inject(Validator validator, Input input) {
    print('hej');
    _input = input;
    validator.validate(_input, guards);
  }

  Map<String, Guard> get guards;

  @override
  T get(String key, [defaultValue]) => _input.get(key, defaultValue);

  @override
  bool has(String key) => _input.has(key);

  @override
  Iterable<String> get keys => _input.keys;

  @override
  Map<String, T> toMap() => _input.toMap();
}

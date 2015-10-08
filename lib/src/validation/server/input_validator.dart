part of bridge.validation;

abstract class InputValidator<T> extends InputBase<T> {
  Input<T> _input;
  Validator _validator;

  $inject(validator, input) {
    _validator = validator;
    _input = input;
  }

  Map<String, Guard> get guards;

  void validate() {
    _validator.validate(_input, guards);
  }

  @override
  T get(String key, [defaultValue]) => _input.get(key, defaultValue);

  @override
  bool has(String key) => _input.has(key);

  @override
  Iterable<String> get keys => _input.keys;

  @override
  Map<String, T> toMap() => _input.toMap();
}

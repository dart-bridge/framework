part of bridge.validation;

abstract class InputValidator {
  final Input _input;

  InputValidator(Input this._input);

  Map<String, String> get filters;

  Future validate() {
    return new Validator().validateAll(_input, filters);
  }

  noSuchMethod(Invocation invocation) {
    return reflect(_input).delegate(invocation);
  }
}

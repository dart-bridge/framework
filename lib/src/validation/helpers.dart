part of bridge.validation.shared;

void validateValue(value, Guard guard) {
  new Validator().validate({'value': value}, {'value': guard});
}

void validate(Map<String, dynamic> values, Map<String, Guard> guards) {
  new Validator().validate(values, guards);
}

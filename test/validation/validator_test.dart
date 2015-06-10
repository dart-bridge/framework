import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/validation.dart';
import 'dart:async';
import 'package:bridge/exceptions.dart';

class ValidatorTest implements TestCase {
  Validator validator;
  bool filterWasCalled;

  setUp() {
    filterWasCalled = false;
    validator = new Validator();
  }

  tearDown() {
  }

  Future<String> isStringFilter(input) async {
    filterWasCalled = true;
    if (input is! String) return 'must be a string';
    return null;
  }

  Future<String> isLowercaseFilter(String input) async {
    if (input.toLowerCase() != input) return 'must be all lower case';
    return null;
  }

  @test
  it_can_register_validation_filters() async {
    validator.registerFilter('isString', isStringFilter);
    await validator.validate('any', 'isString');
    expect(filterWasCalled, equals(true));
  }

  @test
  it_throws_if_the_filter_doesnt_return_null() async {
    validator.registerFilter('isString', isStringFilter);
    expect(validator.validate(0, 'isString'),
    throwsA(const isInstanceOf<ValidationException>()));
  }

  @test
  it_throws_if_trying_to_validate_a_filter_that_isnt_registered() async {
    expect(validator.validate('any', 'isString'),
    throwsA(const isInstanceOf<InvalidArgumentException>()));
  }

  @test
  it_can_validate_against_multiple_filters() async {
    validator.registerFilter('isString', isStringFilter);
    validator.registerFilter('isLowercase', isLowercaseFilter);
    await validator.validate('string', 'isString, isLowercase');
  }

  @test
  it_can_validate_multiple_values() async {
    validator.registerFilter('isString', isStringFilter);
    validator.registerFilter('isLowercase', isLowercaseFilter);
    await validator.validateMany(['string', 'another string'], 'isString, isLowercase');
  }

  @test
  it_can_validate_a_map_against_filters_for_each_key() async {
    validator.registerFilter('isString', isStringFilter);
    validator.registerFilter('isLowercase', isLowercaseFilter);
    await validator.validateAll({
      'first': 'A string',
      'second': 'a lowercase string',
    }, {
      'first': 'isString',
      'second': 'isString,isLowercase',
    });
  }

  @test
  it_throws_when_the_keys_of_the_maps_are_not_identical() {
    expect(validator.validateAll({
      'first': 'A string',
      'second': 'a lowercase string',
    }, {
      'first': 'isString',
    }), throwsA(
      new isInstanceOf<InvalidArgumentException>()
    ));
  }

  @test
  it_has_default_filters() async {
    // required
    await validator.validate('value', 'required');
    await validator.validate(1, 'required');
    await validator.validate(true, 'required');
    expect(validator.validate(null, 'required'), throws);
    expect(validator.validate('', 'required'), throws);
    expect(validator.validate(false, 'required'), throws);
  }
}

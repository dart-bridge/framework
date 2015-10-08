import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/validation.dart';

class ValidatorTest implements TestCase {
  Validator validator;

  setUp() {
    validator = new Validator();
  }

  tearDown() {}

  void expectsFailsValidation(Map<String, dynamic> values,
      Map<String, Guard> guards) {
    expect(() => validator.validate(values, guards),
        throwsA(new isInstanceOf<ValidationException>()));
  }

  @test
  it_does_nothing_when_no_guards_are_supplied() {
    validator.validate({}, {});
    validator.validate({'k': 'v'}, {});
  }

  @test
  it_throws_when_a_guard_returns_a_message() {
    expectsFailsValidation({
      'key': 'value'
    }, {
      'key': (key, value) {
        return 'message';
      }
    });
  }

  @test
  it_comes_with_a_few_built_in_guards() {
    expectsFailsValidation({
    }, {
      'key': Guards.required,
    });

    validator.validate({
      'x': 123,
      'y': '123',
    }, {
      'x': Guards.numeric,
      'y': Guards.numeric,
    });
    expectsFailsValidation({
      'x': 'n',
    }, {
      'x': Guards.numeric,
    });
  }

  @test
  it_can_create_guards_from_function_that_throws() {
    expectsFailsValidation({
      'x': 'y'
    }, {
      'x': Guards.catches((String key, value) {
        throw '';
      }),
    });
  }

  @test
  it_can_merge_multiple_guards() {
    final valid = {
      'x': 1,
    };
    final invalid1 = {
    };
    final invalid2 = {
      'x': 'a'
    };
    final guards = {
      'x': Guards.all([
        Guards.required,
        Guards.numeric,
      ]),
    };

    validator.validate(valid, guards);
    expectsFailsValidation(invalid1, guards);
    expectsFailsValidation(invalid2, guards);
  }
}

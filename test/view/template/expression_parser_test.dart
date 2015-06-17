import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';

class ExpressionParserTest implements TestCase {
  ExpressionParser parser;

  setUp() {
    parser = new ExpressionParser();
  }

  tearDown() {
  }

  @test
  it_parses_strings() async {
    expect(await parser.parse('template'), equals('template'));
  }

  @test
  it_parses_expressions() async {
    expect(await parser.parse(r'${1+1}'), equals('2'));
  }

  @test
  it_can_inject_primitive_variables() async {
    var result = await parser.parse(r'$variable${variable}', {
      'variable': 1337
    });
    expect(result, equals('13371337'));
  }

  @test
  it_can_inject_object_properties() async {
    var result = await parser.parse(
        r'${test.boolProperty ? test.stringProperty : "nope"}',
        {
          'test': new TestClass(),
        });
    expect(result, equals('value'));
  }

  @test
  it_can_inject_values_from_a_map() async {
    var result = await parser.parse(
        r'${test["key"].stringProperty}',
        {
          'test': {
            'key': new TestClass()
          }
        });
    expect(result, equals('value'));
  }

  @test
  it_can_inject_values_from_a_list() async {
    var result = await parser.parse(
        r'${test[0].stringProperty}',
        {
          'test': [
            new TestClass()
          ]
        });
    expect(result, equals('value'));
  }

  @test
  it_can_inject_method_calls() async {
    var result = await parser.parse(
        r'${test[0]("value", 2)}',
        {
          'test': [(String message, num times) {
            return 'parsed$message' * times;
          }]
        });
    expect(result, equals('parsedvalueparsedvalue'));
  }

  @test
  it_can_call_methods_with_variable_values() async {
    var result = await parser.parse(
        r'${method(number)}',
        {
          'method': (num number) {
            return number.toString();
          },
          'number': 2
        });
    expect(result, equals('2'));
  }

  @test
  it_can_inject_a_value_nested_in_different_owners() async {
    var result = await parser.parse(
        r'${test[0]["key"].method().mapProperty["key"]}',
        {
          'test': [
            {'key': new TestClass()}
          ]
        });
    expect(result, equals('value'));
  }

  @test
  it_can_access_global_entities() async {
    expect(await parser.parse(r'${globalFunction()}'),
    equals('response'));
  }
}

globalFunction() {
  return 'response';
}

class TestClass {
  bool boolProperty = true;
  String stringProperty = 'value';
  Map mapProperty = {'key':'value'};
  TestClass method() {
    return new TestClass();
  }
}
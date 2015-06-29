import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';
export 'template_collection_test_helpers.dart';

class TemplateCollectionTest implements TestCase {
  MockTemplateCollection collection;

  setUp() {
    collection = new MockTemplateCollection();
  }

  tearDown() {
  }

  Future expectTemplate(String name, String expectedReturn, [Map<String, dynamic> data = const {}]) async {
    expect(await collection.template(name, data), equals(expectedReturn));
  }

  @test
  it_contains_templates() async {
    expectTemplate('testOne', 'template');
  }

  @test
  it_can_access_variables() async {
    expectTemplate('testTwo', 'value', {'key': 'value'});
  }

  @test
  it_can_access_global_functions_getters_and_setters() async {
    expectTemplate('testThree', 'responseresponsenewResponse');
  }
}

@proxy
class MockTemplateCollection extends TemplateCollection {
  Map<String, TemplateFragmentFunction> get templates => {
    'testOne': () async => 'template',
    'testTwo': () async => '${key}',
    'testThree': () async => '${globalFunction()}${globalVariable}${globalVariable = 'newResponse'}',
  };
}
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';
import 'package:bridge/core.dart';
export 'template_collection_test_helpers.dart';

class TemplateCollectionTest implements TestCase {
  MockTemplateCollection collection;

  setUp() {
    collection = new MockTemplateCollection();
  }

  tearDown() {
  }

  Future expectTemplate(String name,
                        String expectedReturn,
                        {Map<String, dynamic> data : const {},
                        Iterable<String> scripts : const []}) async {
    expect(await collection.template(name, data, scripts), equals(expectedReturn));
  }

  @test
  it_contains_templates() async {
    await expectTemplate('testOne', 'template');
  }

  @test
  it_can_access_variables() async {
    await expectTemplate('testTwo', 'value', data: {'key': 'value'});
  }

  @test
  it_can_access_global_functions_getters_and_setters() async {
    await expectTemplate('testThree', 'responseresponsenewResponse');
  }

  @test
  it_can_inject_development_script_tags_in_html() async {
    Environment.current = Environment.development;
    await expectTemplate(
        'testFour',
        "<html><body>"
        "<script type='application/dart' src='main.dart'></script>"
        "<script type='application/dart' src='test.dart'></script>"
        "</body></html>",
        scripts: ['main', 'test']);
  }

  @test
  it_can_inject_production_script_tags_in_html() async {
    Environment.current = Environment.production;
    await expectTemplate(
        'testFour',
        "<html><body>"
        "<script src='main.dart.js'></script>"
        "<script src='test.dart.js'></script>"
        "</body></html>",
        scripts: ['main', 'test']);
  }
}

@proxy
class MockTemplateCollection extends TemplateCollection {
  Map<String, TemplateFragmentFunction> get templates => {
    'testOne': () async => 'template',
    'testTwo': () async => '${key}',
    'testThree': () async => '${globalFunction()}${globalVariable}${globalVariable = 'newResponse'}',
    'testFour': () async => '<html><body></body></html>',
  };
}
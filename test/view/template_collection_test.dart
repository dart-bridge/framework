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
    expect((await collection.template(name, data, scripts)).parsed, equals(expectedReturn));
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

  @test
  it_can_include_other_templates() async {
    await expectTemplate('testIncludes', '<div>template</div>');
  }

  @test
  it_can_extend_other_templates() async {
    await expectTemplate('testChild', '<div>inner</div>');
  }
}

@proxy
class MockTemplateCollection extends TemplateCollection {
  Map<String, TemplateGenerator> get templates => {
    'testOne': () async => new Template(parsed: 'template'),
    'testTwo': () async => new Template(parsed: '${key}'),
    'testThree': () async => new Template(parsed: '${globalFunction()}${globalVariable}${globalVariable = 'newResponse'}'),
    'testFour': () async => new Template(parsed: '<html><body></body></html>'),
    'testIncludes': () async => new Template(parsed: '<div>${await $include('testOne')}</div>'),
    'testParent': () async => new Template(parsed: '<div>${$block('block')}</div>'),
    'testChild': () async => new Template(parsed: '${await $extends('testParent', {'block': 'inner'})}'),
  };
}
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class TemplateTest implements TestCase {
  Template template;
  MockTemplateLoader loader;
  MockTemplateParser parser;

  setUp() {
    loader = new MockTemplateLoader();
    parser = new MockTemplateParser();
    template = new Template(loader, parser);
  }

  tearDown() {}

  @test
  it_loads_a_template() async {
    loader.template = 'template';
    await template.load('');
    expect(template.contents, equals('template'));
  }

  @test
  it_loads_partials() async {
    loader.template = '<h1>Title</h1>';
    template.contents = '<div><import template="template"/></div>';
    expect(await template.parse(), equals('<div><h1>Title</h1></div>'));
  }

  @test
  it_extends_another_template_by_tag() async {
    loader.template =
    'BeforeParent<tag parent-attr="parent-value">Before<content/>After</tag>';
    template.contents =
    'BeforeChild<tag child-attr="child-value" extends="template">Content</tag>';
    expect(await template.parse(),
    equals(
        'BeforeChild<tag parent-attr="parent-value" child-attr="child-value">BeforeContentAfter</tag>'));
  }

  @test
  it_parses_with_injected_parser() async {
    template.contents = 'SOME_SYNTAX_DETAIL';
    expect(await template.parse(), equals('REPLACEMENT'));
  }

  @test
  it_can_inject_script_tag() async {
    loader.template = '<body></body>';
    await template.load('');
    await template.parse(withScripts: ['main']);
    expect(template.contents, equals("<body><script type='application/dart' src='main.dart'></script></body>"));
    await template.load('');
    await template.parse(withScripts: ['main'], javaScript: true);
    expect(template.contents, equals("<body><script src='main.dart.js'></script></body>"));
  }
}

class MockTemplateLoader implements TemplateLoader {
  String template;

  Future<String> load(String id) async {
    return template;
  }
}

class MockTemplateParser implements TemplateParser {
  String parse(String template, [Map<String, dynamic> data]) {
    return template.replaceFirst('SOME_SYNTAX_DETAIL', 'REPLACEMENT');
  }
}

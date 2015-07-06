import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:io';
import 'dart:async';

class TemplateProcessorTest implements TestCase {
  TemplateProcessor processor;
  List<TemplatePreProcessor> preProcessors;

  setUp() {
    preProcessors = [];
    processor = new TemplateProcessor();
  }

  tearDown() {
  }

  Future<String> _parse(String template, String mainFunction) async {
    await processor.include('test', template, preProcessors: preProcessors);

    var script = processor.templateScript;

    script += mainFunction;

    script = script.replaceFirst('import "dart:async";', 'import "dart:async";export "dart:io";');

    ProcessResult result = await Process.run('dart',
    [
      '-p${Directory.current.absolute.path + '/packages'}',
      'data:application/dart;charset=utf-8,${Uri.encodeComponent(script)}',
    ]);

    if (result.stderr != '')
      throw result.stderr;

    return result.stdout.trim();
  }

  Future<String> parse(String template, [String dataMap = '{}']) async {
    return _parse(template, 'main() async {print((await new Templates().template("test", $dataMap, [])).parsed);}');
  }

  Future<String> data(String template, [String dataMap = '{}']) async {
    return _parse(template, 'main() async {print((await new Templates().template("test", $dataMap, [])).data);}');
  }

  Future<String> asHandlebars(String template) async {
    return _parse(template, 'main() async {print((await new Templates().template("test", {}, [])).asHandlebars);}');
  }

  @test
  empty_template_is_always_string() async {
    expect(await parse(null), equals(''));
    expect(await parse(''), equals(''));
  }

  @test
  it_parses_a_template() async {
    expect(await parse('<div></div>'), equals('<div></div>'));
  }

  @test
  it_parses_expressions() async {
    expect(await parse(r'${1 + 1}'), equals('2'));
  }

  @test
  it_can_parse_expressions_with_local_data() async {
    expect(await parse(r'${variable}', '{"variable":"value"}'), equals('value'));
  }

  @test
  it_can_parse_expressions_with_global_data() async {
    preProcessors.add(new BridgePreProcessor());
    expect(await parse(r'${new dart.io.File.fromUri(Uri.parse("/path"))}'), equals("File: '/path'"));
  }

  @test
  it_can_parse_with_pre_processors() async {
    var processor = new MockPreProcessor();
    preProcessors.add(processor);
    expect(await parse(r'unparsed'), equals('parsed'));
    expect(processor.wasCalled, isTrue);
  }

  @test
  it_keeps_the_data_map() async {
    expect(await data(r'$key', '{"key": "value"}'), equals('{key: value}'));
  }

  @test
  it_keeps_a_handlebars_version() async {
    expect(await asHandlebars(r'$key\$key${key}'), equals(r'{{ key }}$key{{ key }}'));
  }
}

class MockPreProcessor implements TemplatePreProcessor {
  bool wasCalled = false;

  Future<String> process(String template) async {
    wasCalled = true;
    return template.replaceAll('un', '');
  }
}

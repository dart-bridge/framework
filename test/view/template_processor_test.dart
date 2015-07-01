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

  Future<String> parse(String template, [String dataMap = '{}']) async {
    await processor.include('test', template, preProcessors: preProcessors);

    var script = processor.templateScript;

    script+='main() async {print(await new Templates().template("test", $dataMap, []));}';

    ProcessResult result = await Process.run('dart',
    [
      '-p${Directory.current.absolute.path+'/packages'}',
      'data:application/dart;charset=utf-8,${Uri.encodeComponent(script)}',
    ]);

    if (result.stderr != '')
      throw result.stderr;

    return result.stdout.trim();
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
    expect(await parse(r'${new Templates()}'), equals("Instance of 'Templates'"));
  }

  @test
  it_can_parse_with_pre_processors() async {
    var processor = new MockPreProcessor();
    preProcessors.add(processor);
    expect(await parse(r'unparsed'), equals('parsed'));
    expect(processor.wasCalled, isTrue);
  }
}

class MockPreProcessor implements TemplatePreProcessor {
  bool wasCalled = false;
  Future<String> process(String template) async {
    wasCalled = true;
    return template.replaceAll('un', '');
  }
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class MarkdownPreProcessorTest implements TestCase {
  MarkdownPreProcessor processor;

  setUp() {
    processor = new MarkdownPreProcessor();
  }

  tearDown() {}

  Future expectProcessesTo(String template, String result) async {
    expect(await processor.process(template), equals(result));
  }

  @test
  it_supports_empty_template() async {
    await expectProcessesTo(null, '');
    await expectProcessesTo('', '');
  }

  @test
  it_compiles_markdown() async {
    await expectProcessesTo(r'# $expression', r'<h1>$expression</h1>');
  }
}

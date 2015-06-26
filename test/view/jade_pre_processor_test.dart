import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class JadePreProcessorTest implements TestCase {
  JadePreProcessor processor;

  setUp() {
    processor = new JadePreProcessor();
  }

  tearDown() {
  }

  Future expectProcessesTo(String template, String result) async {
    expect(await processor.process(template), equals(result));
  }

  @test
  it_supports_empty_template() async {
    await expectProcessesTo(null, '');
    await expectProcessesTo('', '');
  }

  @test
  it_compiles_jade() async {
    await expectProcessesTo('h1 Text\n\th2 Text', '<h1>Text<h2>Text</h2></h1>');
  }

  @test
  it_precompiles_variables() async {
    var expression = '1 + 2 * (expression.thing() ? 34 : 12)';
    await expectProcessesTo('h1= $expression', '<h1>\${$expression}</h1>');
    await expectProcessesTo('h1 before\${$expression}', '<h1>before\${$expression}</h1>');
  }

  @test
  it_doesnt_escape_quotes() async {
    await expectProcessesTo(
        'form(method="post") Text',
        '<form method="post">Text</form>');
  }

  @test
  it_transforms_include_directive() async {
    await expectProcessesTo(
        'include "partial"',
        '@include("partial")');
  }
}

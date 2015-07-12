import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class HandlebarsPreProcessorTest implements TestCase {
  HandlebarsPreProcessor processor;

  setUp() {
    processor = new HandlebarsPreProcessor();
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
  it_converts_variable_syntax() async {
    await expectProcessesTo(r'{{expression}}', r'${expression}');
  }

  @test
  it_converts_block_syntax() async {
    await expectProcessesTo(r'{{#expression}}content{{/expression}}',
    r'''${await () async {var c = expression;compile() async => """content""";'''
    r'''if (c is bool)return c ? await compile() : '';if (c is Iterable)
    return (await Future.wait(c.map((i) async {var o = data;data = i;
    var r = await compile();data = o;return r;}))).join('');}()}''');
  }

  @test
  it_converts_include_syntax() async {
    await expectProcessesTo(r'{{>partial}}', r'@include (partial)');
  }
}

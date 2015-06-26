import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class BridgePreProcessorTest implements TestCase {
  BridgePreProcessor processor;

  setUp() {
    processor = new BridgePreProcessor();
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
  it_does_nothing_to_plain_html() async {
    await expectProcessesTo('<div></div>', '<div></div>');
  }

  @test
  it_can_have_comments() async {
    await expectProcessesTo('Text// Comment', 'Text');
  }

  @test
  it_knows_when_two_slashes_are_not_a_comment() async {
    await expectProcessesTo('<a href="//notacomment"></a>', '<a href="//notacomment"></a>');
  }

  @test
  it_can_simulate_form_methods() async {
    await expectProcessesTo(
        "<form method='put'></form>",
        "<form method='POST'><input type='hidden' name='_method' value='PUT'></form>");
  }

  @test
  it_has_a_syntax_for_if_statements() async {
    await expectProcessesTo("@if(false)THIS@else if(false)THAT@else THIS@end if",
    r'${await (() async => (false) ? """THIS""" : (false) ? """THAT""" : true ? """THIS""" : "")()}');
  }

  @test
  it_has_a_syntax_for_loops() async {
    await expectProcessesTo("@for(i in l)THIS@end for",
    r'${(await Future.wait((l).map((i) async => """THIS"""))).join("")}');
  }

  @test
  it_has_a_syntax_for_including_partials() async {
    await expectProcessesTo('@include("partial")',
    r'${await $include("partial")}');
  }
}
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';

class BridgePreProcessorTest implements TestCase {
  BridgePreProcessor processor;

  setUp() {
    processor = new BridgePreProcessor();
  }

  tearDown() {
  }

  @test
  it_supports_empty_template() async {
    expect(await processor.process(null), equals(''));
    expect(await processor.process(''), equals(''));
  }

  @test
  it_does_nothing_to_plain_html() async {
    expect(await processor.process('<div></div>'), equals('<div></div>'));
  }

  @test
  it_can_have_comments() async {
    expect(await processor.process('Text// Comment'), equals('Text'));
  }

  @test
  it_knows_when_two_slashes_are_not_a_comment() async {
    expect(await processor.process('<a href="//notacomment"></a>'), equals('<a href="//notacomment"></a>'));
  }

  @test
  it_can_simulate_form_methods() async {
    var before = "<form method='put'></form>";
    var after = "<form method='POST'><input type='hidden' name='_method' value='PUT'></form>";
    expect(await processor.process(before), equals(after));
  }
}
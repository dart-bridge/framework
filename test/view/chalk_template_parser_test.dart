import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class ChalkTemplateParserTest implements TestCase {
  ChalkTemplateParser parser;

  setUp() {
    parser = new ChalkTemplateParser();
  }

  tearDown() {}

  Future _expectParsesTo(List<String> lines, List<String> expected) async {
    expect(
        await parser.parse(new Stream.fromIterable(lines)).toList(),
        equals(expected));
  }

  @test
  it_wraps_lines_in_async_star_yields() async {
    await _expectParsesTo([
      'a',
      'b',
      'c',
    ], [
      "yield '''a''';",
      "yield '''b''';",
      "yield '''c''';",
    ]);
  }

  @test
  it_wraps_variables_in_escape_functions() async {
    await _expectParsesTo([r'$variable'],
        [r"yield '''${$esc(variable)}''';"]);
  }
}

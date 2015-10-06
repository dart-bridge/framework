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

  @test
  it_wraps_expressions_in_escape_functions() async {
    await _expectParsesTo([r"${'1 + 1 = ${1 + 1}'}"],
        [r"yield '''${$esc('1 + 1 = ${1 + 1}')}''';"]);
  }

  @test
  it_converts_an_if_statement() async {
    await _expectParsesTo([
      "@if (true)",
      "@else if (true && (false))",
      "@else",
      "@end if",
    ], [
      r"yield* $if([[true, () async* {",
      r"}], [true && (false), () async* {",
      r"}], [() async* {",
      r"}]]);",
    ]);
  }

  @test
  it_converts_the_new_keyword() async {
    await _expectParsesTo([
      r"${new Thing().getter}",
      r"${'new Thing()'}",
      r"${new Thing(arg1, (arg2))}",
    ], [
      r"yield '''${$esc($new(#Thing)().getter)}''';",
      r"yield '''${$esc('new Thing()')}''';",
      r"yield '''${$esc($new(#Thing)(arg1, (arg2)))}''';",
    ]);
  }

  @test
  it_can_escape_$_and_atsign() async {
    await _expectParsesTo([
      r"\${new Thing().getter}",
      r"\@if (new Thing())",
    ], [
      r"yield '''\${new Thing().getter}''';",
      r"yield '''@if (new Thing())''';",
    ]);
  }

  @test
  it_converts_a_for_in_loop() async {
    await _expectParsesTo([
      r"@for (x in y)",
      r"@end for",
    ], [
      r"yield* $for(y, (x) async* {",
      r"});",
    ]);
  }

  @test
  it_converts_extends_and_block() async {
    await _expectParsesTo([
      r"@extends ('app')",
      r"",
      r"@start block ('content')",
      r"  @block ('inner')",
      r"@end block",
    ], [
      r"yield* $extends('app', {",
      r"",
      r"'content': () async* {",
      r"yield* $block('inner');",
      r"},",
      r"});",
    ]);
  }

  @test
  it_converts_an_include_directive() async {
    await _expectParsesTo([
      r"@include ('partial')",
    ], [
      r"yield* $generate('partial');",
    ]);
  }

  @test
  it_enforces_extends_block_structure() async {
    expect(parser.parse(new Stream.fromIterable([
      r"@extends ('app')",
      r"something",
    ])).toList(), throwsA(new isInstanceOf<ParserException>()));
  }

  @test
  it_has_comments() async {
    await _expectParsesTo([
      r"// comment",
      r"line // comment",
      r"line ${'// not comment'}",
    ], [
      r"",
      r"yield '''line ''';",
      r"yield '''line ${$esc('// not comment')}''';",
    ]);
  }

  @test
  it_has_a_special_syntax_for_not_escaping_variable() async {
    await _expectParsesTo([
      r"$!!variable",
      r"$!!{variable}",
      r"\$!!{variable}",
    ], [
      r"yield '''${variable}''';",
      r"yield '''${variable}''';",
      r"yield '''\$!!{variable}''';",
    ]);
  }
}

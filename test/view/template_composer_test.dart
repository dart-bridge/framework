import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class TemplateComposerTest implements TestCase {
  TemplateComposer manager;
  MockTemplateCacheIo io;

  setUp() {
    io = new MockTemplateCacheIo();
    manager = new TemplateComposer(io);
  }

  tearDown() {}

  @test
  it_uses_a_plain_template_parser_to_parse_template_files() async {
    await manager.cache('some/file.txt',
        new Stream.fromIterable(['a', 'b', 'c',]));
    io.expectPutWasCalled('some.file', [
      "for (final line in '''",
      'a', 'b', 'c',
      r"'''.split('\n')) yield line;",
    ]);
  }

  @test
  it_can_register_other_parsers_for_file_extensions() async {
    manager.registerParser(new StubTemplateParser(), '.stub');
    await manager.cache('some/file.stub',
        new Stream.fromIterable(['a', 'b', 'c']));
    io.expectPutWasCalled('some.file', ['parsed', 'parsed', 'parsed']);
  }

  @test
  it_creates_a_template_cache_file_from_list_of_files() async {
    io.willGet = ["yield '''line''';", "yield '''line2''';"];
    await manager.generateCache(['some/file.stub']);
    io.expectPutContains("""
import 'package:bridge/view.dart';
class Templates extends TemplateCache {
Templates(Map<Symbol, dynamic> variables) : super(variables);
Map<String, TemplateGenerator> get collection => {
'some.file': () async* {
yield '''line''';
yield '''line2''';
},
};
}
    """.trim());
  }

  @test
  the_parsers_can_register_import_statements_for_the_cache_output() async {
    manager.registerParser(new StubTemplateParser(), '.stub', imports: [
      'package:library/library.dart'
    ]);
    await manager.generateCache(['some/file.stub']);
    io.expectPutContains("import 'package:library/library.dart';");
  }
}

class StubTemplateParser implements TemplateParser {
  Stream<String> parse(Stream<String> lines) {
    return lines.map((_) => 'parsed');
  }
}

class MockTemplateCacheIo implements TemplateCacheIo {
  List<String> willGet = [];
  String _getName;
  String _putName;
  List<String> _wasPut = [];

  Stream<String> get(String name) {
    _getName = name;
    return new Stream.fromIterable(willGet);
  }

  void expectGetWasCalled(String name) {
    expect(_getName, equals(name));
  }

  Future put(String name, Stream<String> lines) async {
    _putName = name;
    _wasPut = await lines.toList();
  }

  void expectPutWasCalled(String name, List<String> lines) {
    expect(_putName, equals(name));
    expect(_wasPut, equals(lines));
  }

  void expectPutContains(String content) {
    expect(_wasPut.join('\n'), contains(content));
  }

  Future putTemplateCache(Stream<String> lines) async {
    _wasPut = await lines.toList();
  }

  Future<bool> shouldRecompile(String source, String name) async => true;
}

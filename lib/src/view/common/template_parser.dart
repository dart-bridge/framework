part of bridge.view;

abstract class TemplateParser {
  String get extension;

  Stream<String> parse(Stream<String> lines);
}

class PlainTemplateParser implements TemplateParser {
  Stream<String> parse(Stream<String> lines) async* {
    yield "for (final line in r'''";
    yield* lines;
    yield r"'''.split('\n')) yield line;";
  }

  String get extension => null;
}

part of bridge.view;

abstract class TemplateParser {
  Stream<String> parse(Stream<String> lines);
}

class PlainTemplateParser implements TemplateParser {
  Stream<String> parse(Stream<String> lines) async* {
    yield "for (final line in '''";
    yield* lines;
    yield r"'''.split('\n')) yield line;";
  }
}

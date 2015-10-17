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

class ParserException extends BaseException {
  final int lineNumber;
  String templateName = '<unknown>';

  ParserException(this.lineNumber, String message) : super(message);

  String toString() =>
      '${super.toString()} in template [$templateName] at line $lineNumber';
}

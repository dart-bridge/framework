part of bridge.view;

class ChalkTemplateParser implements TemplateParser {
  Stream<String> parse(Stream<String> lines) {
    return lines.map(_parseLine);
  }

  String _parseLine(String line) {
    return "yield '''$line''';";
  }
}

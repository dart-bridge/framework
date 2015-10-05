part of bridge.view;

class ChalkTemplateParser implements TemplateParser {
  Stream<String> parse(Stream<String> lines) {
    return lines.map(_parseLine);
  }

  String _parseLine(String line) {
    final parsedLine = line
    .replaceAllMapped(_variablePattern, _variableFormat)
    ;
    return "yield '''$parsedLine''';";
  }

  String get extension => '.chalk.html';

  final _variablePattern = new RegExp(r'\$(?:(\w+)|\{(.*?)\})');
  String _variableFormat(Match $) {
    final expression = $[1] ?? $[2];
    return r'${$esc(''$expression'')}';
  }
}

part of bridge.view;

abstract class TemplateParser {
  Future<String> parse(String template, [Map<String, dynamic> data]);
}

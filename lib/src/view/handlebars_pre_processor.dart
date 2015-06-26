part of bridge.view;

class HandlebarsPreProcessor implements TemplatePreProcessor {
  Future<String> process(String template) async {
    if (template == null) return '';
    return _variables(_blocks(template));
  }

  String _blocks(String template) {
    var open = new RegExp(r'{{\s*#([^]*?)}}');
    while (open.hasMatch(template))
      template = template.replaceFirstMapped(open, (m) {
        return r'''${await () async {var c = ''''${m[1]}'''';compile() async => """''';
      });
    var close = new RegExp(r'{{\s*/([^]*?)}}');
    while (close.hasMatch(template))
      template = template.replaceFirstMapped(close, (m) {
        return r'''""";if (c is bool)return c ? await compile() : '';if (c is Iterable)
    return (await Future.wait(c.map((i) async {var o = data;data = i;
    var r = await compile();data = o;return r;}))).join('');}()}''';
      });
    return template;
  }

  String _variables(String template) {
    return template.replaceAllMapped(
        new RegExp(r'{{([^]*?)}}'),
            (m) => '\${${m[1]}}');
  }
}

part of bridge.view;

class JadePreProcessor implements TemplatePreProcessor {
  Map<String, String> _directives = {
    'include': 'include',
  };

  Future<String> process(String template) async {
    template = template == null ? '' : template;
    for (var directive in _directives.keys)
      template = template
      .replaceAllMapped(new RegExp(r'(\s*)''$directive'r'\s+(.*)', multiLine: true), (m) {
        return '${m[1]}| @${_directives[directive]}(${m[2]})';
      });

    var parser = new jade.Parser(template, colons: false);
    var compiler = new jade.Compiler(parser.parse());
    var compiled = compiler.compile();
    var expressionMatcher = new RegExp(
        r'" \+ \(jade\.escape\(null == \(jade\.interp = ([^]*?)\) \? "" : jade\.interp\)\) \+ "');
    var bufferMatcher = new RegExp(r'^buf\.add\("([^]*)"\);$');

    if (!bufferMatcher.hasMatch(compiled)) return '';

    return bufferMatcher.firstMatch(compiler.compile())[1]
    .replaceAllMapped(expressionMatcher, (m) => '\${${m[1]}}')
    .replaceAll(r'\"', '"');
  }
}

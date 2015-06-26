part of bridge.view;

class JadePreProcessor implements TemplatePreProcessor {
  Future<String> process(String template) async {
    template = template == null ? '' : template
    .replaceAllMapped(new RegExp(r'(\s*)include\s+(.*)', multiLine: true), (m) {
      return '${m[1]}| @include(${m[2]})';
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

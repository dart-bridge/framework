part of bridge.view;

class Template {
  TemplateLoader _loader;
  TemplateParser _parser;
  String contents;
  RegExp _importDeclaration = new RegExp(
      r'''<import\s+template=(['"])([\w.]+)\1\s*/>''');
  RegExp _extendsDeclaration = new RegExp(
      r'''^([^]*)<([a-z]+)(.*)extends=(['"])([\w.]+)\4(.*?)>([^]*)</\2>([^]*)$''');

  Template(TemplateLoader this._loader, TemplateParser this._parser);

  Future<String> parse({Map<String, dynamic> withData,
                       List<String> withScripts,
                       bool javaScript: false,
                       TemplateParser withParser}) async {
    var parser = (withParser != null) ? withParser : _parser;
    await _importPartials();
    await _extendParents();
    if (withData == null) withData = {};
    if (withScripts == null) withScripts = [];
    for (var script in withScripts)
      injectScript(script, javaScript: javaScript);
    return _compress(parser.parse(contents, withData));
  }

  Future load(String id) async {
    contents = await _loader.load(id);
  }

  Future _importPartials() async {
    while (_hasImportDeclaration())
      await _importNextPartial();
  }

  bool _hasImportDeclaration() {
    return _importDeclaration.hasMatch(contents);
  }

  Future _importNextPartial() async {
    Match match = _importDeclaration.firstMatch(contents);
    var import = await _loader.load(match[2]);
    contents = contents.replaceFirst(_importDeclaration, import);
  }

  Future _extendParents() async {
    while (_hasExtendsDeclaration())
      await _extendNextParent();
  }

  bool _hasExtendsDeclaration() {
    return _extendsDeclaration.hasMatch(contents);
  }

  Future _extendNextParent() async {
    Match match = _extendsDeclaration.firstMatch(contents);
    var tag = match[2];
    var attributes = match[3].trim() + ' ' + match[6].trim();
    var tagContents = match[7];
    var parent = await _loader.load(match[5]);
    var tagMatcher = _parentExtendTagMatcher(tag);
    var parentMatch = tagMatcher.firstMatch(parent);
    if (parentMatch == null) {
      throw 'Template [${match[5]}] does not contain a <$tag>';
    }
    var contentMatcher = new RegExp('(<content\s*/>|<content>[^]*?</content>)');

    var beforeTag = match[1];
    var parentAttributes = parentMatch[1];
    var afterTag = match[8];
    var parentTagContents = parentMatch[2];
    var extendedTagContent = parentTagContents.replaceFirst(contentMatcher, tagContents);
    var mergedAttributes = '${parentAttributes.trim()} ${attributes.trim()}'.trim();
    if (mergedAttributes != '') mergedAttributes = ' $mergedAttributes';
    contents = '$beforeTag<$tag$mergedAttributes>$extendedTagContent</$tag>$afterTag';
  }

  RegExp _parentExtendTagMatcher(String tag) {
    return new RegExp('''<$tag(.*?)>([^]*)</$tag>''');
  }

  void injectScript(String name, {bool javaScript: false}) {
    var script = "<script";
    if (!javaScript)
      script += " type='application/dart'";
    script += " src='$name.dart";
    if (javaScript)
      script += ".js";
    script += "'></script>";
    contents = contents.replaceFirst('</body>', '$script</body>');
  }

  String _compress(String template) {
    return template
    .replaceAll(new RegExp(r'>\s+'), '> ')
    .replaceAll(new RegExp(r'\s+<'), ' <');
  }
}

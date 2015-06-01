part of bridge.view;

typedef Future<Template> TemplateProvider(String templateName);

class Template {
  String markup = '';
  final List<String> scripts = [];
  final Map<String, dynamic> data = {};
  Map<String, Template> _dependencies = {};
  TemplateProvider _templateProvider = (t) async => await new Template();

  Template([String this.markup]);

  void templateProvider(TemplateProvider provider) {
    _templateProvider = provider;
  }

  Future<String> get headMarkup => _contentsOfTag('head');

  Future<String> get bodyMarkup async {
    String bodyContents = await _contentsOfTag('body');
    return bodyContents + _scriptsMarkup();
  }

  String _scriptsMarkup() {
    return scripts.map((script){
      return '<script src="/$script.dart" type="application/dart"></script>';
    }).join('');
  }

  Future<String> get templateMarkup => _contentsOfTag('template');

  Future<String> _contentsOfTag(String tagName) async {
    Match match = new RegExp('<$tagName.*?>([^]*)</$tagName>').firstMatch(markup);
    if (match == null) return '';
    var contents = await _injectDependencyTemplates(tagName, match[1]);
    return _injectData(tagName, contents);
  }

  Future<String> _injectDependencyTemplates(String tagName, String template) async {
    var dependencyMatcher = new RegExp(r'{{>\s*(.*?)\s*}}');
    while (dependencyMatcher.hasMatch(template)) {
      var nextMatch = dependencyMatcher.firstMatch(template);
      if (_dependencies.containsKey(nextMatch[1]))
        template = template.replaceFirst(dependencyMatcher, await _dependencies[nextMatch[1]]._contentsOfTag(tagName));
      else await _dependOnTemplate(nextMatch[1]);
    }
    return template;
  }

  Future<String> _injectData(String tagName, String template) async {
    var t = new mustache.Template(template);
    return t.renderString(data);
  }

  Future _dependOnTemplate(String templateName) async {
    _dependencies[templateName] = await _templateProvider(templateName);
  }
}
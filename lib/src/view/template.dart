part of bridge.view;

typedef Future<Template> TemplateProvider(String templateName);

class Template {

  String markup = '';

  Template([String this.markup]);

  TemplateProvider _templateProvider = (t) async => await new Template();

  Map<String, Template> _dependencies = {};

  void templateProvider(TemplateProvider provider) {
    _templateProvider = provider;
  }

  Future<String> get headMarkup => _contentsOfTag('head');

  Future<String> get bodyMarkup => _contentsOfTag('body');

  Future<String> get templateMarkup => _contentsOfTag('template');

  Future<String> _contentsOfTag(String tagName) async {
    Match match = new RegExp('<$tagName.*?>([^]*)</$tagName>').firstMatch(markup);
    if (match == null) return '';
    return _injectDependencyTemplates(tagName, match[1]);
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

//  Future<String> _injectDependencyTemplates(String tagName, String template) async {
//    return template.replaceAllMapped(new RegExp(r'{{>\s*(.*?)\s*}}'), await (Match match) async {
//      Template injectTemplate = await _templateProvider(match[1]);
//      return injectTemplate._contentsOfTag(tagName);
//    });
//  }
//
//  Future<String> _injectTemplate(String tagName, Template template) async {
//    var templateContents = await template._contentsOfTag(tagName);
//
//  }

  Future _dependOnTemplate(String templateName) async {
    _dependencies[templateName] = await _templateProvider(templateName);
  }
}
part of bridge.view;

class DocumentBuilder {
  TemplateRepository _repository;

  DocumentBuilder(TemplateRepository this._repository);

  Future<String> fromTemplate(Template template) async {
    template.templateProvider(_repository.find);
    return _htmlTag((await _headTag(template)) + (await _bodyTag(template)));
  }

  String _htmlTag(String contents) {
    return '<!DOCTYPE html><html>$contents</html>';
  }

  Future<String> _headTag(Template template) {
    return _tag('head', template);
  }

  Future<String> _bodyTag(Template template) async {
    String tagContents = await template.bodyMarkup;
    return '<body>$tagContents</body>';
  }

  Future<String> _tag(String tagName, Template template) async {
    String tagContents = await template._contentsOfTag(tagName);
    return '<$tagName>$tagContents</$tagName>';
  }

  Future<String> fromTemplateName(String templateName, [List<String> scripts, Map<String, dynamic> data]) async {
    Template template = await _repository.find(templateName);
    if (scripts is List<String>)
      template.scripts.addAll(scripts);
    if (data is Map<String, dynamic>)
      template.data.addAll(data);
    return fromTemplate(template);
  }
}
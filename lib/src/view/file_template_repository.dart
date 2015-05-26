part of bridge.view;

class FileTemplateRepository implements TemplateRepository {
  Directory _templateDirectory;

  FileTemplateRepository(Config config) {
    _templateDirectory = new Directory(config('app.templates.root', 'lib/templates'));
  }

  Future<Template> find(String templateName) async {
    File templateFile = new File(_pathFromTemplateName(templateName));
    if (!(await templateFile.exists())) {
      throw new TemplateNotFoundException(templateName);
    }
    return new Template(await templateFile.readAsString());
  }

  String _pathFromTemplateName(String templateName) {
    return _templateDirectory.path + '/' + templateName.replaceAll('.', '/') + '.hbs';
  }
}
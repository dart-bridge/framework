part of bridge.view;

class FileTemplateLoader implements TemplateLoader {
  String _templateDir;

  FileTemplateLoader(Config config) {
    _templateDir = config('view.templates.root','lib/templates');
  }

  Future<String> load(String id) {
    return new File('$_templateDir/${id.replaceAll('.','/')}.btl').readAsString();
  }
}

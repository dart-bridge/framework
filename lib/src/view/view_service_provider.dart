part of bridge.view;

class ViewServiceProvider implements ServiceProvider {
  Application app;
  Program program;
  TemplateComposer composer;
  static bool didCompile = false;
  final List<String> templateFiles = [];

  void setUp(Application app, TemplateCacheIo io) {
    final composer = new TemplateComposer(io);
    this.composer = composer;
    this.app = app;
    app.singleton(composer);
    app.resolve(_registerParsers);
  }

  void _registerParsers() {
    composer.registerParser(app.presolve((ChalkTemplateParser p) => p));
  }

  Future load(Program program, Server server) async {
    this.program = program;
    final root = new Directory(
        app.config('view.templates.root', 'lib/templates'));

    await for (File file in root.list(recursive: true)) {
      if (await FileSystemEntity.isFile(file.path)) {
        final source = path.relative(file.path, from: root.path);
        templateFiles.add(source);
        await composer.cache(source, file.openRead()
            .map(UTF8.decode)
            .expand((String multiLine) => multiLine.split('\n')));
      }
    }

    server.modulateRouteReturnValue((Template template) {
      if (template is! Template) return template;
      return template.content.join('\n');
    });
  }

  Future run() async {
    if (didCompile) {
      await composer.generateCache(templateFiles);
      await program.reload();
    }
  }
}

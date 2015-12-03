part of bridge.view;

class ViewServiceProvider extends ServiceProvider {
  Application app;
  Program program;
  TemplateComposer composer;
  static bool didCompile = false;
  final List<String> templateFiles = [];

  void setUp(Application app, TemplateCacheIo io) {
    final composer = new TemplateComposer(io);
    this.composer = composer;
    this.app = app;
    _helperContainer = app;
    app.singleton(composer);
    app.resolve(_registerParsers);
  }

  void _registerParsers() {
    composer.registerParser(app.curry((ChalkTemplateParser p) => p));
  }

  Future load(Program program, ViewConfig config) async {
    this.program = program;
    final root = new Directory(config.templatesRoot);

    await Future.wait(await root.list(recursive: true).map((File file) async {
      if (!path.basename(file.path).startsWith('.')
          && await FileSystemEntity.isFile(file.path)) {
        final source = path.relative(file.path, from: root.path);
        templateFiles.add(source);
        try {
          await composer.cache(source, file.openRead()
              .map(UTF8.decode)
              .expand((String multiLine) => multiLine
              .split(new RegExp(r'[\r\n]+'))));
        } on ParserException catch(e) {
          print('<red>$e</red>');
        }
      }
    }).toList());
  }

  Future run() async {
    if (didCompile) {
      await composer.generateCache(templateFiles);
      await program.reload();
    }
  }
}

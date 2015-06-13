part of bridge.view;

class ViewServiceProvider implements ServiceProvider {
  bool javaScriptTags;
  String publicDirectory;
  Program program;
  Container container;

  setUp(Container container, Config config, Program program) async {
    this.container = container;
    this.program = program;
    var env = config.env('APP_ENV', 'production');
    javaScriptTags = (env == 'production');
    var parserId = config('view.parse_to', 'html');
    Type parser = parserId == null
    ? null
    : _templateParsers.containsKey(parserId)
    ? _templateParsers[parserId]
    : throw new TemplateException('Parser [$parserId] does not exist');
    container.bind(TemplateParser, parser);
    container.bind(TemplateLoader, FileTemplateLoader);
    publicDirectory = config('http.server.publicRoot', 'web');
    program.addCommand(build);
  }

  Future<String> _parseTemplateResponse(Template template, TemplateResponse templateResponse) async {
    var parser = (templateResponse.parser != null)
    ? container.make(templateResponse.parser)
    : container.make(TemplateParser);
    await template.load(templateResponse.templateName);
    String contents = await template.parse(
        withData: templateResponse.data,
        withScripts: templateResponse.scripts,
        javaScript: javaScriptTags,
        withParser: parser);
    return contents;
  }

  load(Server server, Template template, TetherManager tethers) {
    tethers.registerHandler((Tether tether) {
      tether.modulateBeforeSerialization((TemplateResponse value) async {
        if (value is! TemplateResponse) return value;
        value.parser = BtlToHandlebarsParser;
        var contents = await _parseTemplateResponse(template, value);
        return {
          'template': contents,
          'data': value.data,
        };
      });
    });
    server.modulateRouteReturnValue((TemplateResponse value) async {
      if (value is! TemplateResponse) return value;
      var contents = await _parseTemplateResponse(template, value);
      return '<!DOCTYPE html><html>$contents</html>';
    });
  }

  @Command('Compile front end .dart files to .js')
  build() async {
    var files = await new Directory(publicDirectory).list(recursive: true, followLinks: false).toList();
    await Future.wait(files.map((File file) async {
      FileStat stat = await file.stat();
      if (stat.type != FileSystemEntityType.FILE) return null;

      if (!file.path.endsWith('.dart')) return null;

      var outFile = '${file.path}.js';

      program.printInfo('Compiling ${file.path}');

      Process process = await Process.start('dart2js', ['-m', '-o', outFile, file.path]);

      var sub = process.stdout.map(UTF8.decode).listen(stdout.writeln);

      int exitCode = await process.exitCode;
      await sub.cancel();
      if (exitCode == 0) return program.printAccomplishment('$outFile generated successfully.');
      program.printDanger('$outFile could not be generated! [Exit code $exitCode]');
    }));
  }


//  DocumentBuilder builder;
//
//  setUp(Application application) {
//    application.bind(TemplateRepository, FileTemplateRepository);
//  }
//
//  load(Server server, DocumentBuilder builder) {
//    this.builder = builder;
//    server.modulateRouteReturnValue(_returnValueModulation);
//  }
//
//  _returnValueModulation(value) {
//    if (value is ViewResponse)
//      return _viewResponse(value, builder);
//    if (value is Template)
//      return _templateResponse(value, builder);
//    return value;
//  }
//
//  Future<String> _viewResponse(ViewResponse response, DocumentBuilder builder) {
//    return builder.fromTemplateName(
//        response.templateName,
//        response.scripts,
//        response.data);
//  }
//
//  Future<String> _templateResponse(Template template, DocumentBuilder builder) {
//    return builder.fromTemplate(template);
//  }
}
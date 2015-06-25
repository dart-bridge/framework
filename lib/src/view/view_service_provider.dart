part of bridge.view;

TemplateCollection _templates;

class ViewServiceProvider implements ServiceProvider {
  Directory templatesDirectory;
  File templatesCache;
  Program program;

  setUp(Config config,
        Container container,
        Program program) {
    this.program = program;
    templatesDirectory = new Directory(config('view.templates.root', 'lib/templates'));
    templatesCache = new File(config('view.templates.cache', '.templates.dart'));

    ClassMirror templatesClass = plato.classMirror(#Templates);
    if (templatesClass == null)
      return program.printWarning('Templates cache weren\'t loaded. Try [export "${templatesCache.path}";] in any library.');

    container.bind(TemplateCollection, templatesClass.reflectedType);

    _templates = container.make(TemplateCollection);
  }

  load(TemplateProcessor processor) async {
    await loadTemplates(processor);
  }

  Future loadTemplates(TemplateProcessor processor) async {
    List<File> templateFiles = await listTemplateFiles().toList();
    DateTime templateFilesChanged = await latestChange(templateFiles);
    DateTime templatesCacheChanged = await latestChange([templatesCache]);

    if (templateFilesChanged.isBefore(templatesCacheChanged))
      return;

    for (File templateFile in templateFiles)
      await processor.include(
          templateId(templateFile.path),
          await templateFile.readAsString(),
          preProcessors: preProcessorsOf(extension(templateFile.path)));

    await templatesCache.writeAsString(processor.templateScript);

    program.printInfo('Templates compiled to [${templatesCache.path}]');

    await program.reload();
  }

  String templateId(String path) {
    return path.replaceFirst('${templatesDirectory.path}/', '')
    .replaceFirst(new RegExp('${extension(path)}\$'), '')
    .replaceAll('/', '.');
  }

  Stream<File> listTemplateFiles() {
    return templatesDirectory.list(recursive: true, followLinks: false)
      .where((f) => FileSystemEntity.isFileSync(f.path));
  }

  Future<DateTime> latestChange(List<File> files) async {
    DateTime latest;
    await for (DateTime changed in new Stream.fromIterable(files)
    .asyncMap((File f) => f.stat())
    .asyncMap((FileStat s) => s.modified))
      latest = latest == null
      ? changed : changed.isAfter(latest)
      ? changed : latest;
    return latest == null ? new DateTime.fromMillisecondsSinceEpoch(0) : latest;
  }

  List<TemplatePreProcessor> preProcessorsOf(String extension) {
    var all = <String, List<TemplatePreProcessor>>{
      '.jade': [
//        new JadePreProcessor(),
//        new BridgePreProcessor(),
      ],
      '.hbs': [
//        new HandlebarsPreProcessor(),
//        new BridgePreProcessor(),
      ],
      '.html': [
//        new BridgePreProcessor(),
      ],
    };
    return all.containsKey(extension) ? all[extension] : [];
  }
}
part of bridge.view;

abstract class TemplateCacheIo {
  factory TemplateCacheIo(Config config)
  => new _TemplateCacheIo(config);

  Future put(String name, Stream<String> lines);

  Future putTemplateCache(Stream<String> lines);

  Stream<String> get(String name);

  Future<bool> shouldRecompile(String source, String name);
}

class _TemplateCacheIo implements TemplateCacheIo {
  final File _templateCacheFile;
  final Directory _templateCacheDirectory;
  final Directory _templateRoot;

  _TemplateCacheIo(Config config)
      :
        _templateRoot = new Directory(config(
            'view.template.root', 'lib/templates')),
        _templateCacheFile = new File(config(
            'view.templates.cache', '.templates.dart')),
        _templateCacheDirectory = new Directory(config(
            'view.templates.cache_directory', '.templates'));

  File _cacheFile(String name) {
    return new File(path.join(_templateCacheDirectory.path, name));
  }

  Future put(String name, Stream<String> lines) async {
    ViewServiceProvider.didCompile = true;
    return _writeLines(_cacheFile(name), lines);
  }

  Stream<String> get(String name) {
    return _cacheFile(name).openRead().map(UTF8.decode);
  }

  Future putTemplateCache(Stream<String> lines) {
    return _writeLines(_templateCacheFile, lines);
  }

  Future _writeLines(File file, Stream<String> lines) async {
    if (!await file.exists()) await file.create(recursive: true);
    final sink = file.openWrite();
    await sink.addStream(lines.map((l) => '$l\n').map(UTF8.encode));
    await sink.close();
  }

  Future<bool> shouldRecompile(String source, String name) async {
    final sourceFile = new File(path.join(_templateRoot.path, source));
    final stat = await sourceFile.stat();
    final cacheFile = _cacheFile(name);
    if ((!await cacheFile.exists())) return true;
    final cacheStat = await cacheFile.stat();
    return stat.modified.isAfter(cacheStat.modified);
  }
}

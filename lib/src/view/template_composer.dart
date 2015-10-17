part of bridge.view;

class TemplateComposer {
  final TemplateCacheIo _io;
  final Map<String, Function> _parsers = {};
  final Set<String> _imports = new Set<String>();

  TemplateComposer(TemplateCacheIo this._io);

  Future cache(String filename, Stream<String> lines) async {
    final parser = _pickParser(filename);
    final name = _nameTemplate(filename, parser.extension);
    if (await _io.shouldRecompile(filename, name)) {
      final streams = new StreamSplitter(parser.parse(lines));
      try {
        await _validateParsedTemplate(
            filename, await streams.split().join('\n'));
        await _io.put(name, streams.split());
        print('<blue>Template [$name] was compiled.</blue>');
      } on ParserException catch (e) {
        e.templateName = name;
        await _io.put(name, _errorTemplate(e));
        rethrow;
      } on FormatException catch (e) {
        throw new ParserException(-1, '$e')..templateName = name;
      }
    }
  }

  Stream<String> _errorTemplate(ParserException e) {
    final message = e.message
        .replaceAll('yield \'\'\'', '')
        .replaceAll('\'\'\';', '')
        .replaceAll('\'\'\'', '\'');
    return new PlainTemplateParser().parse(
        new Stream.fromIterable('''
        <h1>ParserException on line ${e.lineNumber}</h1>
        <pre>$message</pre>
        '''.trim().split('\n')));
  }

  TemplateParser _pickParser(String filename) {
    final parser = _parsers.keys
        .firstWhere((ext) => filename.endsWith(ext), orElse: () => null);
    if (parser == null) return new PlainTemplateParser();
    return _parsers[parser]();
  }

  String _nameTemplateFromFilename(String filename) {
    final parser = _pickParser(filename);
    return _nameTemplate(filename, parser.extension);
  }

  String _nameTemplate(String filename, String extension) {
    final extensionPartCount = extension
        ?.split('.')
        ?.where((s) => s != '')
        ?.length
        ?? 1;
    return filename
        .split(new RegExp(r'[/\\]'))
        .join('.')
        .split('.')
        .reversed
        .skip(extensionPartCount)
        .toList()
        .reversed
        .join('.');
  }

  void registerParser(TemplateParser factory(),
      {List<String> imports: const []}) {
    _parsers[factory().extension] = factory;
    _imports.addAll(imports);
  }

  Future generateCache(List<String> filenames) async {
    return _io.putTemplateCache(() async* {
      final Iterable<String> names = filenames.map(_nameTemplateFromFilename);
      final Iterable<Stream<String>> templates = names.map(_io.get);
      final templateMap = new Map.fromIterables(names, templates);

      yield "import 'package:bridge/view.dart';";
      for (final import in _imports)
        yield "import '$import';";
      yield "class Templates extends TemplateCache {";
      yield "Templates(Map<Symbol, dynamic> variables) : super(variables);";
      yield "Map<String, TemplateGenerator> get collection => {";
      for (final name in templateMap.keys) {
        yield "'$name': () async* {";
        yield* templateMap[name];
        yield "},";
      }
      yield "};";
      yield "}";
    }());
  }

  Future<String> _validateParsedTemplate(String filename,
      String template) async {
    final content = 'main() {} template() async* {\n$template}';
    final uri = Uri.parse(
        'data:application/dart;charset=utf-8,${Uri.encodeComponent(content)}');

    final errorPort = new ReceivePort();
    final exitPort = new ReceivePort();
    final commPort = new ReceivePort();

    final completer = new Completer();

    var output = '';

    errorPort.listen((err) {
      if (!completer.isCompleted)
        completer.completeError(err);
    });
    exitPort.listen((_) {
      if (!completer.isCompleted)
        completer.complete(output);
    });
    commPort.listen((message) {
      output += 'message\n';
    });

    await Isolate.spawnUri(uri, [], commPort.sendPort,
        onExit: exitPort.sendPort,
        onError: errorPort.sendPort,
        errorsAreFatal: false).catchError((err) {
      if (!completer.isCompleted)
        completer.completeError(err);
    });

    try {
      return await completer.future.whenComplete(() {
        errorPort.close();
        exitPort.close();
        commPort.close();
      });
    } catch (e) {
      final error = e.toString()
          .replaceFirst('IsolateSpawnException: ', '')
          .replaceFirst('\'data:${uri.path}\': error: ', '');
      final match = new RegExp(r'line (\d+) pos (\d+): ([^]*)')
          .firstMatch(error);
      final lineNumber = int.parse(match[1]) - 1;
//      final columnNumber = int.parse(match[2]);
      final message = match[3];
      throw new ParserException(
          lineNumber, 'Template [$filename] failed to compile: ${message}');
    }
  }
}

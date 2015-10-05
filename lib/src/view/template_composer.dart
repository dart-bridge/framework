part of bridge.view;

class TemplateComposer {
  final TemplateCacheIo _io;
  final Map<String, TemplateParser> _parsers = {};
  final Set<String> _imports = new Set<String>();

  TemplateComposer(TemplateCacheIo this._io);

  Future cache(String filename, Stream<String> lines) async {
    final parser = _pickParser(filename);
    final name = _nameTemplate(filename, parser.extension);
    if (await _io.shouldRecompile(filename, name))
      await _io.put(name, parser.parse(lines));
  }

  TemplateParser _pickParser(String filename) {
    final parser = _parsers.keys
        .firstWhere((ext) => filename.endsWith(ext), orElse: () => null);
    if (parser == null) return new PlainTemplateParser();
    return _parsers[parser];
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

  void registerParser(TemplateParser parser, {List<String> imports: const []}) {
    _parsers[parser.extension] = parser;
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
}

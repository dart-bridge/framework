part of bridge.view;

class TemplateComposer {
  final TemplateCacheIo _io;
  final Map<String, TemplateParser> _parsers = {};
  final Set<String> _imports = new Set<String>();

  TemplateComposer(TemplateCacheIo this._io);

  Future cache(String filename, Stream<String> lines) async {
    final name = _nameTemplate(filename);
    if (await _io.shouldRecompile(filename, name))
      await _io.put(name, _pickParser(filename).parse(lines));
  }

  TemplateParser _pickParser(String filename) {
    final parser = _parsers.keys
        .firstWhere((ext) => filename.endsWith(ext), orElse: () => null);
    if (parser == null) return new PlainTemplateParser();
    return _parsers[parser];
  }

  String _nameTemplate(String filename) {
    return filename
        .split(new RegExp(r'[/\\]'))
        .join('.')
        .split('.')
        .reversed
        .skip(1)
        .toList()
        .reversed
        .join('.');
  }

  void registerParser(TemplateParser parser,
      String extension, {List<String> imports: const []}) {
    _parsers[extension] = parser;
    _imports.addAll(imports);
  }

  Future generateCache(List<String> filenames) async {
    return _io.putTemplateCache(() async* {
      final Iterable<String> names = filenames.map(_nameTemplate);
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

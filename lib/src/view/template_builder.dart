part of bridge.view;

@proxy
class TemplateBuilder implements Future<Template> {
  final String _name;
  final Map<Symbol, dynamic> _data = {};
  final List<String> _scripts = [];

  TemplateBuilder(String this._name);

  TemplateBuilder withScript(String script) {
    _scripts.add(script);
    return this;
  }

  TemplateBuilder withScripts(List<String> scripts) {
    _scripts.addAll(scripts);
    return this;
  }

  TemplateBuilder withData(Map variables) {
    _data.addAll(new Map.fromIterables(
        variables.keys.map((k) => k is Symbol ? k : new Symbol('$k')),
        variables.values
    ));
    return this;
  }

  void noSuchMethod(Invocation invocation) {
    if (!invocation.isSetter)
      super.noSuchMethod(invocation);

    final key = MirrorSystem
        .getName(invocation.memberName)
        .replaceFirst('=', '');

    _data[new Symbol(key)] = invocation.positionalArguments[0];
  }

  Future<Template> _build() async {
    final Stream<String> stream = _attachScripts(
        new TemplateCache.import(_data).$generate(_name));
    return new Template(stream, data: new Map.fromIterables(
        _data.keys.map(MirrorSystem.getName),
        _data.values
    ));
  }

  Stream<String> _attachScripts(Stream<String> lines) async* {
    var scriptsAdded = false;
    await for (final String line in lines) {
      if (line.contains('</body>')) {
        yield line.replaceAll('</body>', '${_formatScriptTags()}</body>');
        scriptsAdded = true;
      } else yield line;
    }
    if (!scriptsAdded)
      yield _formatScriptTags();
  }

  String _formatScriptTags() {
    final buffer = new StringBuffer();
    for (final script in _scripts) {
      if (Environment.isProduction)
        buffer.write("<script src='/$script.dart.js'></script>");
      else
        buffer.write(
            "<script type='application/dart' src='/$script.dart'></script>");
    }
    return buffer.toString();
  }

  Stream<Template> asStream() {
    return new Stream.fromFuture(_build());
  }

  Future catchError(Function onError, {bool test(Object error)}) {
    return _build().catchError(onError, test: test);
  }

  Future then(onValue(Template value), {Function onError}) {
    return _build().then(onValue, onError: onError);
  }

  Future timeout(Duration timeLimit, {onTimeout()}) {
    return _build().timeout(timeLimit, onTimeout: onTimeout);
  }

  Future<Template> whenComplete(action()) {
    return _build().whenComplete(action);
  }
}

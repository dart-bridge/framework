part of bridge.view;

_TemplateBuilder template(String templateName,
    {String withScript,
    List<String> withScripts,
    Map<String, dynamic> withData: const {}}) {
  List<String> scripts = withScripts != null ? withScripts.toList() : [];

  if (withScript != null) scripts.add(withScript);

  return new _TemplateBuilder(templateName)
    .._data.addAll(withData)
    .._scripts.addAll(scripts);
}

// Temporary, will be replaced with an integrated Template Builder
@proxy
class _TemplateBuilder implements Future<Template> {
  final String _name;
  final Map<String, dynamic> _data = {};
  final List<String> _scripts = [];

  _TemplateBuilder(String this._name);

  _TemplateBuilder withScript(String script) {
    _scripts.add(script);
    return this;
  }

  void noSuchMethod(Invocation invocation) {
    if (!invocation.isSetter)
      super.noSuchMethod(invocation);

    final key = MirrorSystem
        .getName(invocation.memberName)
        .replaceFirst('=', '');

    _data[key] = invocation.positionalArguments[0];
  }

  Future<Template> _build() {
    return _templates.template(_name, _data, _scripts);
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

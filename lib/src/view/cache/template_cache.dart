part of bridge.view;

typedef Stream<String> TemplateGenerator();

@proxy
abstract class TemplateCache {
  final Map<Symbol, dynamic> _variables;
  Map<String, TemplateGenerator> _blocks = {};

  TemplateCache(Map<Symbol, dynamic> this._variables);

  static ClassMirror __templatesClass;

  static ClassMirror get _templatesClass =>
      __templatesClass ??= plato.classMirror(#Templates);

  factory TemplateCache.import(Map<Symbol, dynamic> variables) {
    return plato.instantiate(_templatesClass, [variables]);
  }

  Map<String, TemplateGenerator> get collection;

  Stream<String> $generate(String template) => collection[template]?.call();

  noSuchMethod(Invocation invocation) {
    final target = _getTarget(invocation);
    if (target == null) return null;
    if (target is Type) return new _StaticAccessor(target);
    if (invocation.isGetter)
      return target;
    if (target is Function)
      return (reflect(target) as ClosureMirror)
          .apply(invocation.positionalArguments, invocation.namedArguments)
          .reflectee;
    super.noSuchMethod(invocation);
  }

  Object _getTarget(Invocation invocation) {
    if (_variables.containsKey(invocation.memberName))
      return _variables[invocation.memberName];
    try {
      return plato
          .instance(invocation.memberName)
          ?.reflectee;
    } catch (e) {
      return null;
    }
  }

  // Helpers

  dynamic $new(Symbol type, List positional, Map<Symbol, dynamic> named) {
    return plato.instantiate(plato.classMirror(type), positional, named);
  }

  Stream<String> $if(List<List> components) {
    for (final component in components)
      if (component.length == 1) return component[0]();
      else if (component[0]) return component[1]();
    return new Stream.empty();
  }

  String $esc(String input) {
    if (input == null) return '';
    return new HtmlEscape().convert(input);
  }

  Stream<String> $for(items, Stream<String> callback(item)) async* {
    if (items is Stream)
      await for (final item in items)
        yield* callback(item);
    else if (items is Iterable)
      for (final item in items)
        yield* callback(item);
    else throw new InvalidArgumentException(
          '@for directive can only take streams or iterables');
  }

  Stream<String> $block(String block) {
    if (_blocks.containsKey(block))
      return _blocks[block]();
    return new Stream.empty();
  }

  Stream<String> $extends(String parent,
      Map<String, TemplateGenerator> blocks) async* {
    _blocks.addAll(blocks);
    yield* $generate(parent);
    blocks.keys.forEach(_blocks.remove);
  }
}

class _StaticAccessor {
  final ClassMirror _target;

  _StaticAccessor(target) : _target = reflectType(target);

  noSuchMethod(Invocation invocation) {
    if (invocation.isGetter)
      return _target
          .getField(invocation.memberName)
          .reflectee;
    if (invocation.isSetter)
      return _target
          .setField(invocation.memberName,
          invocation.positionalArguments[0])
          .reflectee;
    return _target.delegate(invocation);
  }
}

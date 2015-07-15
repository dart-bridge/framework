part of bridge.view;

typedef Future<Template> TemplateGenerator();

typedef Future<String> TemplateForEachIteration(element);

abstract class TemplateCollection {
  Map<String, TemplateGenerator> get templates;

  Map<String, dynamic> data;

  final Map<String, String> _blocks = <String, String>{};

  noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #$instantiate) return _instantiate(invocation);
    try {
      var key = MirrorSystem.getName(invocation.memberName);
      if (data.containsKey(key)) return data[key];
      var dataInstance = reflect(data);
      if (dataInstance != null
      && dataInstance.type.declarations.containsKey(invocation.memberName))
        return dataInstance.delegate(invocation);
      var instance = plato.instance(invocation.memberName);
      if (instance != null) {
        var instanceValue = instance.reflectee;
        if (instanceValue is Type) return new StaticAccessor(instance);
        if (invocation.isGetter) return instanceValue;
        return (instance as ClosureMirror)
        .apply(invocation.positionalArguments, invocation.namedArguments).reflectee;
      }
    } catch (e) {
    }
    return null;
  }

  Object _instantiate(Invocation invocation) {
    var positional = invocation.positionalArguments.toList();
    Symbol symbol = positional.removeAt(0);
    var symbolSegments = MirrorSystem.getName(symbol).split('.');
    Symbol constructor = const Symbol('');
    if (symbolSegments.last.contains(new RegExp(r'^[a-z]'))) {
      constructor = new Symbol(symbolSegments.removeLast());
      symbol = new Symbol(symbolSegments.join('.'));
    }
    var named = invocation.namedArguments;
    return plato.instantiate(plato.classMirror(symbol), positional, named, constructor);
  }

  Future<Template> $include(String name) async {
    if (!templates.containsKey(name))
      throw new InvalidArgumentException('No template [$name] is cached.');
    return await templates[name]();
  }

  String $escape(String template) {
    return new HtmlEscape().convert(template);
  }

  Future<String> $extends(String parent, Map<String, String> blocks) async {
    _blocks.addAll(blocks);
    var parsed = (await $include(parent)).parsed;
    _blocks.clear();
    return parsed;
  }

  String $block(String block) {
    return _blocks.containsKey(block) ? _blocks[block] : '';
  }

  Future<Template> template(String name,
                            Map<String, dynamic> data,
                            List<String> scripts) async {
    this.data = data;
    return _attachScripts(await $include(name), scripts);
  }

  Template _attachScripts(Template template, List<String> scripts) {
    String markup = template.parsed;

    productionTag(s) => "<script src='$s.dart.js'></script>";

    developmentTag(s) => "<script type='application/dart' src='$s.dart'></script>";

    return new Template(
        data: template.data,
        parsed: markup.replaceFirstMapped(new RegExp(r'(</\s*body\s*>|$)'), (m) {
          return "${scripts
          .map(Environment.isProduction ? productionTag : developmentTag)
          .join('')}${m[1]}";
        }));
  }
}

class StaticAccessor {
  InstanceMirror _type;

  StaticAccessor(InstanceMirror this._type);

  noSuchMethod(Invocation invocation) {
    ClassMirror classMirror = reflectClass(_type.reflectee);
    if (invocation.isGetter)
      return classMirror.getField(invocation.memberName).reflectee;
    if (invocation.isSetter)
      return classMirror.setField(invocation.memberName, invocation.positionalArguments[0]).reflectee;
    return classMirror.invoke(
        invocation.memberName,
        invocation.positionalArguments,
        invocation.namedArguments).reflectee;
  }
}

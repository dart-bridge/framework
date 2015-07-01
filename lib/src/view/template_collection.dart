part of bridge.view;

typedef Future<String> TemplateFragmentFunction();

typedef Future<String> TemplateForEachIteration(element);

abstract class TemplateCollection {
  Map<String, TemplateFragmentFunction> get templates;
  Map<String, dynamic> data;

  noSuchMethod(Invocation invocation) {
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
        if (invocation.isGetter) return instanceValue;
        return (instance as ClosureMirror)
        .apply(invocation.positionalArguments, invocation.namedArguments).reflectee;
      }
    } catch(e) {}
    return null;
  }

  Future<String> $include(String name) async {
    if (!templates.containsKey(name))
      throw new InvalidArgumentException('No template [$name] is cached.');
    return await templates[name]();
  }

  Future<String> template(String name,
                          Map<String, dynamic> data,
                          List<String> scripts) async {
    this.data = data;
    return _attachScripts(await $include(name), scripts);
  }

  String _attachScripts(String markup, List<String> scripts) {
    productionTag(s) => "<script src='$s.dart.js'></script>";
    developmentTag(s) => "<script type='application/dart' src='$s.dart'></script>";

    return markup.replaceFirstMapped(new RegExp(r'(</\s*body\s*>|$)'), (m) {
      return "${scripts
      .map(Environment.isProduction ? productionTag : developmentTag)
      .join('')}${m[1]}";
    });
  }
}

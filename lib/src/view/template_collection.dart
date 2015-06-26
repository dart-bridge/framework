part of bridge.view;

typedef Future<String> TemplateCollectionItem();

abstract class TemplateCollection {
  Map<String, TemplateCollectionItem> get templates;
  Map<String, dynamic> data;

  noSuchMethod(Invocation invocation) {
    var key = MirrorSystem.getName(invocation.memberName);
    if (data.containsKey(key)) return data[key];
    var dataInstance = reflect(data);
    if (dataInstance.type.declarations.containsKey(invocation.memberName))
      return dataInstance.delegate(invocation);
    var instance = plato.instance(invocation.memberName);
    if (instance != null) return instance.reflectee;
    return null;
  }

  Future<String> template(String name,
                          Map<String, dynamic> data) {
    this.data = data;
    if (!templates.containsKey(name))
      throw new InvalidArgumentException('No template [$name] is cached.');
    return templates[name]();
  }
}

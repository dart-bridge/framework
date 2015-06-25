part of bridge.view;

typedef Future<String> TemplateCollectionItem();

abstract class TemplateCollection {
  Map<String, TemplateCollectionItem> get templates;
  Map<String, dynamic> _data;

  noSuchMethod(Invocation invocation) {
    var key = MirrorSystem.getName(invocation.memberName);
    if (_data.containsKey(key)) return _data[key];
    var instance = plato.instance(invocation.memberName);
    if (instance != null) return instance;
    return super.noSuchMethod(invocation);
  }

  Future<String> template(String name,
                          Map<String, dynamic> data) {
    _data = data;
    if (!templates.containsKey(name))
      throw new InvalidArgumentException('No template [$name] is cached.');
    return templates[name]();
  }
}

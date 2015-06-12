part of bridge.database.in_memory;

class InMemoryDatabase implements Database {
  final Map<String, InMemoryCollection> _collections = {};

  Future close() async {
  }

  Collection collection(String name) {
    return _getOrCreateCollection(name);
  }

  Collection _getOrCreateCollection(String name) {
    if (!_collections.containsKey(name))
      _collections[name] = new InMemoryCollection();
    return _collections[name];
  }

  Future connect(Config config) async {
  }
}

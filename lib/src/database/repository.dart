part of bridge.database;

class Repository<M> implements Collection {
  final String collectionName = null;
  Database _database;
  Collection _collection;
  Container _container;
  Selector select;

  Repository(Container this._container, Database this._database) {
    _setCollection();
  }

  void _setCollection() {
    var collectionName = this.collectionName;
    if (collectionName == null)
      collectionName = MirrorSystem.getName(reflectType(M).simpleName).toLowerCase() + 's';
    _collection = _database.collection(collectionName);
    select = _collection.select;
  }

  M _instantiateModelFromFields(Map<String, dynamic> fields) {
    var instance = reflect(_container.make(M));
    for (var fieldName in fields.keys) {
      var symbol = new Symbol(fieldName);
      if (instance.type.instanceMembers.containsKey(symbol))
        instance.setField(symbol, fields[fieldName]);
    }
    return instance.reflectee;
  }

  Map<String, dynamic> _fieldsFromModel(M model) {
    var fieldNames = _getFields(model);
    var fields = <String, dynamic>{};
    var mirror = reflect(model);
    for (var fieldName in fieldNames)
      fields[MirrorSystem.getName(fieldName)] = mirror.getField(fieldName).reflectee;
    return fields;
  }

  Iterable<Symbol> _getFields(M model) {
    var instance = reflect(model);
    var symbols = <Symbol>[];
    var fields = _allFields(instance.type);
    for (var symbol in fields.keys)
      if (fields[symbol].metadata.any((m) => m.reflectee == field))
        symbols.add(symbol);
    return symbols;
  }

  Map<Symbol, DeclarationMirror> _allFields(ClassMirror mirror) {
    var declarations = new Map.from(mirror.declarations);
    if (mirror.superclass != reflectClass(Object))
      declarations.addAll(_allFields(mirror.superclass));
    return declarations;
  }

  List<M> _instantiateModelsFromListOfFields(List<Map> listOfFields) {
    return listOfFields.map(_instantiateModelFromFields).toList();
  }

  Future<List<M>> all() async {
    return _instantiateModelsFromListOfFields(await _collection.all());
  }

  Future<M> find(id) async {
    return _instantiateModelFromFields(await _collection.find(id));
  }

  Future<List<M>> get(Selector query) async {
    return _instantiateModelsFromListOfFields(await _collection.get(query));
  }

  Future<M> first(Selector query) async {
    return _instantiateModelFromFields(await _collection.first(query));
  }

  Selector where(String field,
                 {isEqualTo,
                 isNotEqualTo,
                 isLessThan,
                 isGreaterThan,
                 isLessThanOrEqualTo,
                 isGreaterThanOrEqualTo}) {
    return _collection.where(
        field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isGreaterThan: isGreaterThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
  }

  Future save(M model) async {
    var fields = _fieldsFromModel(model);
    fields['updatedAt'] = new DateTime.now();
    if (fields['createdAt'] == null)
      fields['createdAt'] = fields['updatedAt'];
    (model as Model).id = await _collection.save(fields);
  }

  Future delete(M model) async {
    var fields = _fieldsFromModel(model);
    await _collection.delete(fields);
  }
}

part of bridge.database;

class DatabaseServiceProvider implements ServiceProvider {

  Application app;

  Future setUp(Config config, Application app) async {

    this.app = app;

    String dbName = config['database.mongo.database'];
    if (dbName == null) dbName = 'database';

    String dbHost = config['database.mongo.hostname'];
    if (dbHost == null) dbHost = 'localhost';

    String dbPort = config['database.mongo.port'];
    if (dbPort == null) dbPort = '27017';

    Objectory database = new ObjectoryDirectConnectionImpl(
        'mongodb://$dbHost:$dbPort/$dbName',
        _registerModels,
        false
    );

    objectory = database;

    await database.initDomainModel();

    app.singleton(database, as: Objectory);
  }

  _registerModels() {

    var allModels = _getAllModelClasses();

    for (var model in allModels) {

      objectory.registerClass(model, () {

        Model instance = app.make(model);

        var mirror = reflect(instance);

        var fields = instance._getModelFieldNames();

        fields.forEach((field) async {

          var fieldName = MirrorSystem.getName(field);

          // model.field = model.getProperty('field')
          mirror.setField(field, instance.getProperty(fieldName));
        });

        return instance;
      });
    }
  }

  List<Type> _getAllModelClasses() {
    var allModels = <Type>[];

    currentMirrorSystem().libraries.forEach((key, LibraryMirror library) {

      library.declarations.forEach((key, declaration) {

        if (declaration is ClassMirror) {

          ClassMirror classMirror = cast(declaration);

          var modelMirror = reflectClass(Model);

          if (classMirror.isSubclassOf(modelMirror) && classMirror != modelMirror) {

            allModels.add(classMirror.reflectedType);
          }
        }
      });
    });
    return allModels;
  }

  Future tearDown(Objectory db) async {

    await db.close();
  }
}
part of bridge.database;

class DatabaseServiceProvider implements ServiceProvider {
  Database database;

  Future setUp(Config config, Container container) async {
    String driver = config('database.driver', 'mongodb');

    if (driver == 'mongodb') await _setUpMongo(config);
    else throw new ConfigException('Driver [$driver] is not implemented.');

    container.singleton(database, as: Database);
  }

  Future _setUpMongo(Config config) async {
    database = new MongoDatabase();

    await database.connect(config);
  }

  Future tearDown() {
    return database.close();
  }
}
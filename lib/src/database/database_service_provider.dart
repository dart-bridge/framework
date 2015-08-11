part of bridge.database;

class DatabaseServiceProvider implements ServiceProvider {
  Database database;

  Future setUp(Config config, Container container) async {
    String driver = config('database.driver', 'mongodb');

    if (driver == 'in_memory') await _setUpInMemory(config);
    else if (driver == 'mongodb') await _setUpMongo(config);

    else throw new ConfigException('Driver [$driver] is not implemented.');

    container.singleton(database, as: Database);
  }

  Future _setUpInMemory(Config config) async {
    database = new InMemoryDatabase();
  }

  Future _setUpMongo(Config config) async {
    try {
      database = new MongoDatabase();

      await database.connect(config);
    } on SocketException {
      var port = config('database.mongodb.port', 27017);
      throw new ConfigException('No MongoDB server is running on port $port. '
      'Check your configuration or remove [bridge.database.DatabaseServiceProvder] '
      'from your service provider list.');
    }
  }

  Future tearDown() {
    return database.close();
  }
}
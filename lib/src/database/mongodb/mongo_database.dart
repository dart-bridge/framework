part of bridge.database.mongodb;

class MongoDatabase implements Database {
  mongo.Db _database;

  Collection collection(String name) {
    return new MongoCollection(_database.collection(name));
  }

  Future connect(Config config) async {
    _database = new mongo.Db(_uri(config));
  }

  String _uri(Config config) {
    int port = config('database.mongodb.port', 27017);
    String database = config('database.mongodb.database', 'app');
    return 'mongodb://localhost:$port/$database';
  }
}

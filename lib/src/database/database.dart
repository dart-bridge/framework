part of bridge.database;

abstract class Database {
  Collection collection(String name);

  Future connect(Config config);
}

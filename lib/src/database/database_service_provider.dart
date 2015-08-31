part of bridge.database;

class DatabaseServiceProvider implements ServiceProvider {
  Gateway gateway;

  Future setUp(Application app) async {
    gateway = new Gateway();
  }
}
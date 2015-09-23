part of bridge.database;

Gateway _gateway;

class Repository<M> extends trestle.Repository<M> {
  Repository() {
    super.connect(_gateway);
  }
}

class DatabaseServiceProvider implements ServiceProvider {
  Future setUp(Application app, Container container) async {
    _gateway = new Gateway(_chooseDriver(app));
    app.singleton(_gateway);
  }

  Future load() async {
    await _gateway.connect();
  }

  Future tearDown() async {
    await _gateway.disconnect();
  }

  Driver _chooseDriver(Application app) {
    switch (app.config('database.driver', 'in_memory')) {
      case 'in_memory':
        return new InMemoryDriver();
      case 'my_sql':
        final conf = 'database.drivers.my_sql';
        return new MySqlDriver(
            host: app.config('$conf.host', 'localhost'),
            port: app.config('$conf.port', 3306),
            username: app.config('$conf.username', 'root'),
            password: app.config('$conf.password'),
            database: app.config('$conf.database', 'database'),
            max: app.config('$conf.max', 5),
            maxPacketSize: app.config('$conf.max_packet_size', 16 * 1024 * 1024),
            ssl: app.config('$conf.ssl', false));
      case 'sqlite':
        final conf = 'database.drivers.sqlite.file';
        return new SqliteDriver(app.config(conf, ':memory:'));
      case 'postgres':
        final conf = 'database.drivers.postgres';
        return new PostgresqlDriver(
            host: app.config('$conf.host', 'localhost'),
            port: app.config('$conf.port', 5432),
            username: app.config('$conf.username', 'root'),
            password: app.config('$conf.password', 'password'),
            database: app.config('$conf.database', 'database'),
            ssl: app.config('$conf.ssl', false));
      default:
        throw new ConfigException(
            '${app.config('database.driver')} '
                'is not an available database driver');
    }
  }
}
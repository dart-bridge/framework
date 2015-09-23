part of bridge.database;

Gateway _gateway;

class Repository<M> extends trestle.Repository<M> {
  Repository() {
    super.connect(_gateway);
  }
}

class DatabaseServiceProvider implements ServiceProvider {
  Application _app;
  Program _program;

  Future setUp(Application app, Container container) async {
    _app = app;
    _gateway = new Gateway(_chooseDriver(app));
    app.singleton(_gateway);
  }

  Future load(Program program) async {
    _program = program;
    program.addCommand(db_migrate);
    program.addCommand(db_rollback);
    program.addCommand(db_refresh);
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
            maxPacketSize: app.config(
                '$conf.max_packet_size', 16 * 1024 * 1024),
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

  Set<Type> _migrations;

  Set<Type> _getMigrations() {
    final migrationStrings = _app.config('database.migrations', []);
    if (migrationStrings is! List)
      throw new ConfigException('[database.migrations] must be a list');
    return migrationStrings
        .map((n) => plato.classMirror(new Symbol(n)))
        .map((m) => m.reflectedType)
        .toSet();
  }

  Set<Type> get migrations => _migrations ??= _getMigrations();

  @Command('Migrate the database')
  db_migrate() async {
    await _gateway.migrate(migrations);
    _program.printAccomplishment('Database successfully migrated');
  }

  @Command('Roll back all database migrations')
  db_rollback() async {
    await _gateway.rollback(migrations);
    _program.printAccomplishment('Database successfully rolled back');
  }

  @Command('Roll back and re migrate all database migrations')
  db_refresh() async {
    await db_rollback();
    await db_migrate();
  }
}

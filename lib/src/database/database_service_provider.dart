part of bridge.database;

@DependsOn(EventsServiceProvider, strict: false)
class DatabaseServiceProvider extends ServiceProvider {
  Program _program;
  Gateway _gateway;
  DatabaseConfig _config;

  Future setUp(Application app, Container container) async {
    _config = new DatabaseConfig(app.config);
    var driver = _chooseDriver(_config);
    if (driver is SqlDriver) {
      driver = container.make(EventEmittingSqlDriver, injecting: {
        SqlDriver: driver
      });
      app.singleton(driver, as: SqlDriver);
    }
    app.singleton(driver);
    app.singleton(driver, as: Driver);
    app.singleton(_gateway = new Gateway(driver));
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

  Driver _chooseDriver(DatabaseConfig config) {
    switch (config.driver) {
      case 'in_memory':
        return new InMemoryDriver();
      case 'my_sql':
        return new MySqlDriver(
            host: config.mySqlHost,
            port: config.mySqlPort,
            username: config.mySqlUsername,
            password: config.mySqlPassword,
            database: config.mySqlDatabase,
            max: config.mySqlMax,
            maxPacketSize: config.mySqlMaxPacketSize,
            ssl: config.mySqlSsl);
      case 'sqlite':
        return new SqliteDriver(config.sqliteFile);
      case 'postgres':
        return new PostgresqlDriver(
            host: config.postgresHost,
            port: config.postgresPort,
            username: config.postgresUsername,
            password: config.postgresPassword,
            database: config.postgresDatabase,
            ssl: config.postgresSsl);
      default:
        throw new ConfigException(
            '${config.driver} '
                'is not an available database driver');
    }
  }

  Set<Type> _migrations;

  Set<Type> _getMigrations() {
    final migrationStrings = _config.migrations;
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

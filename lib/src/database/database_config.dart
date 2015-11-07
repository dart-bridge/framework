part of bridge.database;

class DatabaseConfig {
  final Config _config;

  DatabaseConfig(this._config);

  String get _driver => 'database.driver';

  String get _drivers => 'database.drivers';

  String get _sqlite => '$_drivers.sqlite';

  String get _mySql => '$_drivers.my_sql';

  String get _postgres => '$_drivers.postgres';

  String get driver => _config(_driver, 'in_memory');

  Map<String, Map> get drivers => _config(_drivers, {
    'sqlite': sqlite,
    'my_sql': mySql,
    'postgres': postgres,
  });

  Map<String, dynamic> get sqlite => _config(_sqlite, {
    'file': sqliteFile
  });

  String get sqliteFile =>
      _config('$_sqlite.file', 'storage/.database.db');

  Map<String, dynamic> get mySql => _config(_mySql, {
    'host': mySqlHost,
    'port': mySqlPort,
    'username': mySqlUsername,
    'password': mySqlPassword,
    'database': mySqlDatabase,
    'ssl': mySqlSsl,
    'max': mySqlMax,
    'max_packet_size': mySqlMaxPacketSize,
  });

  String get mySqlHost =>
      _config('$_mySql.host', 'localhost');

  int get mySqlPort =>
      _config('$_mySql.port', 3306);

  String get mySqlUsername =>
      _config('$_mySql.username',
          _config.env('APP_DB_USER'));

  String get mySqlPassword =>
      _config('$_mySql.password',
          _config.env('APP_DB_PASSWORD'));

  String get mySqlDatabase =>
      _config('$_mySql.database',
          _config.env('APP_DB_DATABASE'));

  bool get mySqlSsl =>
      _config('$_mySql.ssl',
          _config.env('APP_DB_SECURE', 'false'));

  int get mySqlMax =>
      _config('$_mySql.max', 5);

  int get mySqlMaxPacketSize =>
      _config('$_mySql.max_packet_size', 16777216);

  Map<String, dynamic> get postgres => _config(_postgres, {
    'host': postgresHost,
    'port': postgresPort,
    'username': postgresUsername,
    'password': postgresPassword,
    'database': postgresDatabase,
    'ssl': postgresSsl,
  });

  String get postgresHost => _config('$_postgres.host', 'localhost');

  int get postgresPort => _config('$_postgres.port', 5432);

  String get postgresUsername =>
      _config('$_postgres.username', _config.env('APP_DB_USER'));

  String get postgresPassword =>
      _config('$_postgres.password', _config.env('APP_DB_PASSWORD'));

  String get postgresDatabase =>
      _config('$_postgres.database', _config.env('APP_DB_DATABASE'));

  bool get postgresSsl =>
      _config('$_postgres.ssl', _config.env('APP_DB_SECURE', 'false'));

  List<String> get migrations => _config('database.migrations', []);
}

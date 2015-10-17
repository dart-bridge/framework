part of bridge.database;

class EventEmittingSqlDriver extends SqlDriver {
  final SqlDriver _driver;
  final Events _events;

  EventEmittingSqlDriver(SqlDriver this._driver, Events this._events);

  Stream execute(String statement, List variables) {
    final event = new SqlWasSent(statement, variables);
    SqlWasSent.history.add(event);
    _events.fire(event);
    return _driver.execute(statement, variables);
  }

  String get autoIncrementKeyword => _driver.autoIncrementKeyword;

  Future connect() => _driver.connect();

  Future disconnect() => _driver.disconnect();

  @override
  String parseSchemaColumn(Column column) {
    return _driver.parseSchemaColumn(column);
  }

  String wrapSystemIdentifier(String systemId) {
    return _driver.wrapSystemIdentifier(systemId);
  }
}

class SqlWasSent {
  final String statement;
  final List variables;
  static final List<SqlWasSent> history = [];

  const SqlWasSent(String this.statement, List this.variables);
}

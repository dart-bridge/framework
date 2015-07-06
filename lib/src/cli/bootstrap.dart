part of bridge.cli;

/// Entry point for the server side application. The `arguments` and `message`
/// arguments should be passed directly from the main function. The `configPath`
/// is the relative path to the root config directory. This will be passed
/// into the [Application] and bootstrap the entire system.
bootstrap(List<String> arguments, {String configPath}) async {
  if (arguments.contains('--production')) {
    _printToLog = true;
    arguments.remove('--production');
  }
  await _makeProgram(configPath).run(arguments);
}

bool _printToLog = false;

Program _makeProgram(configPath) {
  return new BridgeCli(_chooseConfigPath(configPath), printToLog: _printToLog);
}

String _chooseConfigPath(String configPath) {
  return (configPath == null) ? 'config' : configPath;
}
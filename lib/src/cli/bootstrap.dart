part of bridge.cli;

/// Entry point for the server side application. The `arguments` and `message`
/// arguments should be passed directly from the main function. The `configPath`
/// is the relative path to the root config directory. This will be passed
/// into the [Application] and bootstrap the entire system.
bootstrap(List<String> arguments, {String configPath}) async {
  await _makeProgram(arguments, configPath).run();
}

bool _printToLog = false;

Program _makeProgram(List<String> arguments, configPath) {
  return new BridgeCli(_createInitialInput(arguments.toList()), _chooseConfigPath(configPath), printToLog: _printToLog);
}

Input _createInitialInput(List<String> arguments) {
  if (arguments.contains('--production')) {
    _printToLog = true;
    arguments.remove('--production');
  }
  if (arguments.isEmpty) return null;
  return new Input(arguments);
}

String _chooseConfigPath(String configPath) {
  return (configPath == null) ? 'config' : configPath;
}
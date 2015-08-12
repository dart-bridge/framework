part of bridge.cli;

/// Entry point for the server side application. The `arguments` and `message`
/// arguments should be passed directly from the main function. The `configPath`
/// is the relative path to the root config directory. This will be passed
/// into the [Application] and bootstrap the entire system.
bootstrap(List<String> args, {String configPath}) async {
  var arguments = args.toList();
  if (arguments.contains('--production')) {
    _printToLog = true;
    arguments.remove('--production');
  }
  await _makeProgram(configPath, arguments).run(arguments);
}

bool _printToLog = false;

Program _makeProgram(configPath, arguments) {
  return new BridgeCli(arguments, _chooseConfigPath(configPath), printToLog: _printToLog);
}

String _chooseConfigPath(String configPath) {
  return (configPath == null) ? 'config' : configPath;
}
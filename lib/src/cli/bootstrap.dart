part of bridge.cli;

/// Entry point for the server side application. The `arguments` and `message`
/// arguments should be passed directly from the main function. The `configPath`
/// is the relative path to the root config directory. This will be passed
/// into the [Application] and bootstrap the entire system.
bootstrap(List<String> args, {String configPath}) async {
  final List arguments = args?.toList() ?? [];
  var shell = new Shell();
  if (arguments.contains('--production')) {
    shell = new Shell(null, new FileOutputDevice());
    arguments.remove('--production');
  }
  return new BridgeCli(arguments, _chooseConfigPath(configPath), shell)
      .run(arguments.join(' '));
}

String _chooseConfigPath(String configPath) {
  return (configPath == null) ? 'config' : configPath;
}
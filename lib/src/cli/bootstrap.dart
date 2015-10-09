part of bridge.cli;

/// Entry point for the server side application. The `arguments` and
/// `connector` arguments should be passed directly from the main function. The
/// `configPath` is the relative path to the root config directory. This will be
/// passed into the [Application] and bootstrap the entire system.
bootstrap(List<String> arguments, connector, {String configPath}) async {
  final List args = arguments?.toList() ?? [];
  var shell = new Shell();
  var production = false;
  if (args.contains('--production')) {
    production = true;
    shell = new Shell(
        new SilentInputDevice(),
        new FileOutputDevice('storage/bridge.log'));
  }
  return cupid(new BridgeCli(_chooseConfigPath(configPath), shell, production),
      args, connector);
}

String _chooseConfigPath(String configPath) {
  return (configPath == null) ? 'config' : configPath;
}
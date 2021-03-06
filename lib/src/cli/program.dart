part of bridge.cli;

class BridgeCli extends Program {
  final Application app = new Application();
  final String _configPath;
  final bool _setProduction;

  BridgeCli(this._configPath, Shell shell, [this._setProduction])
      : super(shell) {
    app..singleton(this)..singleton(this, as: Program);
  }

  setUp() async {
    await app.setUp(_configPath);
    if (_setProduction) Environment.current = Environment.production;
    InputDevice.prompt = new Output('<cyan>=</cyan> ');
  }

  tearDown() async {
    await unwatch();
    await app.tearDown();
  }

  @override
  Future run({String bootArguments: '', stdinBroadcast, reloadPort}) {
    return super.run(
        bootArguments: bootArguments.replaceAll('--production', ''),
        stdinBroadcast: stdinBroadcast,
        reloadPort: reloadPort);
  }

  bool _watching = false;
  bool _reloading = false;
  StreamSubscription _watchSubscription;

  @Command('Watch your project files for changes')
  watch() async {
    if (_watching) {
      printWarning('Already watching!');
      return;
    }
    _watching = true;
    _watchSubscription = new Watcher(Directory.current.path)
        .events
        .listen((WatchEvent event) async {
      if (path.split(event.path).any((s) => s.startsWith('.'))) return;
      if (_reloading || path.basename(event.path).startsWith('.')) return;
      printAccomplishment('Reloading...');
      _reloading = true;
      await reload(['watch']);
    });

    printInfo('Watching files...');
  }

  @Command('Stop watching your project files for changes')
  unwatch() async {
    if (!_watching) return;
    await _watchSubscription.cancel();
    if (!_reloading) printInfo('Stopped watching files');
    _watching = false;
  }

  @Command('Build the projects client side assets using [pub build]')
  build() async {
    final buildPath = app.config('http.server.build_root', 'build');
    final buildRootDirectory = new Directory(buildPath);
    final tempDirectory = await (buildRootDirectory.parent.createTemp());

    printInfo('Building client in $buildPath');

    await _run('pub', ['build', '-o', tempDirectory.path]);

    if (await buildRootDirectory.exists())
      await buildRootDirectory.delete(recursive: true);

    await tempDirectory.rename(buildPath);

    printAccomplishment('Client was built successfully');
  }

  Future _run(String executable, List<String> arguments) async {
    final process = await Process.start(executable, arguments);
    process.stdout
        .map(UTF8.decode)
        .map((s) => _colorizeOutput(executable, s))
        .listen(this.print);
    process.stderr
        .map(UTF8.decode)
        .map((s) => _colorizeOutput(executable, s))
        .listen(this.print);
    final exitCode = await process.exitCode;

    if (exitCode != 0) printDanger('Exited with exit code $exitCode');
  }

  String _colorizeOutput(String executable, String line) {
    return '<gray>[<gray><cyan>$executable</cyan><gray>] ${line.trim()}</gray>';
  }
}

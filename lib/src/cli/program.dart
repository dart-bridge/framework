part of bridge.cli;

class BridgeCli extends Program {
  Application app;
  String _configPath;

  BridgeCli(String this._configPath, {bool printToLog: false})
  : super(io: printToLog ? new LogIoDevice() : null) {
    app = new Application()
      ..singleton(this)
      ..singleton(this, as: Program);
  }

  setUp() async {
    await app.setUp(_configPath);
    this.setPrompter('<cyan>=</cyan> ');
  }

  tearDown() async {
    await unwatch();
    await app.tearDown();
  }

  bool _watching = false;
  StreamSubscription _watchSubscription;

  @Command('Watch your project files for changes')
  watch() async {
    if (_watching) {
      printWarning('Already watching!');
      return;
    }
    _watching = true;
    var arguments = Platform.executableArguments.isEmpty
    ? ['watch']
    : [',watch']..addAll(Platform.executableArguments);
    _watchSubscription = Directory.current.watch(recursive: true).listen((event) async {
      await reload(arguments);
    });
    printInfo('Watching files...');
  }

  @Command('Stop watching your project files for changes')
  unwatch() async {
    if (!_watching) return;
    await _watchSubscription.cancel();
    _watching = false;
    printInfo('Stopped watching files');
  }
}

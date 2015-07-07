part of bridge.cli;

class BridgeCli extends Program {
  Application app;
  String _configPath;
  List<String> _arguments;

  BridgeCli(List<String> this._arguments, String this._configPath, {bool printToLog: false})
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
  bool _reloading = false;
  StreamSubscription _watchSubscription;

  @Command('Watch your project files for changes')
  watch() async {
    if (_watching) {
      printWarning('Already watching!');
      return;
    }
    _watching = true;
    var arguments = this._arguments.isEmpty
    ? ['watch']
    : ['watch,']
      ..addAll(this._arguments.toList().where((s) => !new RegExp(r',?watch,?').hasMatch(s)));
    _watchSubscription = Directory.current.watch(recursive: true).listen((event) async {
      if (path.split(event.path).any((s) => s.startsWith('.'))) return;
      if (_reloading || path.basename(event.path).startsWith('.')) return;
      printAccomplishment('Reloading...');
      _reloading = true;
      await reload(arguments);
    });
    printInfo('Watching files...');
  }

  @Command('Stop watching your project files for changes')
  unwatch() async {
    if (!_watching) return;
    await _watchSubscription.cancel();
    if (!_reloading)
      printInfo('Stopped watching files');
    _watching = false;
  }
}

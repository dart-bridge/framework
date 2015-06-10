part of bridge.cli;

class BridgeCli extends Program {
  Application app;
  String _configPath;
  Input _initialInput;

  BridgeCli(Input this._initialInput, String this._configPath, {bool printToLog: false})
  : super(io: printToLog ? new LogIoDevice() : null) {
    app = new Application()
      ..singleton(this)
      ..singleton(this, as: Program);
  }

  setUp() async {
    await app.setUp(_configPath);
    this.setPrompter('<cyan>=</cyan> ');
    if (_initialInput != null)
      execute(_initialInput);
  }

  tearDown() async {
    await app.tearDown();
  }
}

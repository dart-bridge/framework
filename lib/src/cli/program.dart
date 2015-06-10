part of bridge.cli;

class BridgeCli extends Program {

  Application app;
  String _configPath;

  BridgeCli(String this._configPath) {
    app = new Application()
    ..singleton(this)
    ..singleton(this, as: Program);
  }

  setUp() async {
    await app.setUp(_configPath);
    this.setPrompter('<cyan>=</cyan> ');
  }

  tearDown() async {
    await app.tearDown();
  }
}

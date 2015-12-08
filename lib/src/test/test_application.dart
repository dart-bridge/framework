part of bridge.test;

class TestApplication extends Application {
  final Config _config;
  BridgeCli _program;
  TestServer _server;
  final _InputOutput _io = new _InputOutput();

  TestApplication._(List<Type> serviceProviders, {Map config})
      : _config = new Config(config ?? {}),
        super() {
    final Iterable<String> serviceProviderQualifiedNames = serviceProviders
        .map(reflectType)
        .map((TypeMirror m) => m.qualifiedName)
        .map(MirrorSystem.getName);

    _config['app'] ??= {};
    _config['app']['service_providers'] ??= [];
    _config['app']['service_providers'].addAll(serviceProviderQualifiedNames);

    _init();
  }

  void _init() {
    Environment.current = Environment.testing;
    _program = new BridgeCli(null, new Shell(_io, _io));

    singleton(_program);
    singleton(_program, as: Program);
    singleton(this);
    singleton(this, as: Application);
    singleton(this, as: Container);
  }

  TestApplication._full(this._config) : super() {
    _init();
  }

  List<String> get log => _io.log;

  TestServer get server {
    if (!hasServiceProvider(http.HttpServiceProvider))
      throw new UnsupportedError(
          'You must include [HttpServiceProvider] to use HTTP.');

    return _server ??= make(TestServer);
  }

  Future execute(String command) async {
    _io.output(await _program.execute(new Input(command)));
  }

  static Future<TestApplication> start(List<Type> serviceProviders,
      {Map config}) async {
    final app = new TestApplication._(serviceProviders, config: config);
    await app.setUp();
    return app;
  }

  static Future<TestApplication> startFull(
      {String configDirectory: 'config'}) async {
    final config = await Config.load(new Directory(configDirectory));
    final app = new TestApplication._full(config);
    await app.setUp();
    return app;
  }

  Future setUp([_]) {
    return runZoned(() {
      return super.setUpWithConfig(_config);
    }, zoneSpecification: new ZoneSpecification(print: (Zone self,
        ZoneDelegate parent,
        Zone zone,
        String line) {
      _io.output(new Output('$line'));
    }));
  }
}

part of bridge.test;

class TestApplication extends Application {
  final Config _config;
  BridgeCli _program;
  final _InputOutput _io = new _InputOutput();

  TestApplication._(List<Type> serviceProviders, {Map config})
      : _config = new Config(config ?? {}),
        super() {
    Environment.current = Environment.testing;
    _program = new BridgeCli(null, new Shell(_io, _io));

    final Iterable<String> serviceProviderQualifiedNames = serviceProviders
        .map(reflectType)
        .map((TypeMirror m) => m.qualifiedName)
        .map(MirrorSystem.getName);

    _config['app'] ??= {};
    _config['app']['service_providers'] ??= [];
    _config['app']['service_providers'].addAll(serviceProviderQualifiedNames);

    singleton(_program);
    singleton(_program, as: Program);
    singleton(this);
    singleton(this, as: Application);
    singleton(this, as: Container);
  }

  List<String> get log => _io.log;

  Future execute(String command) async {
    _io.output(await _program.execute(new Input(command)));
  }

  static Future<TestApplication> start(List<Type> serviceProviders, {Map config}) async {
    final app = new TestApplication._(serviceProviders, config: config);
    await app.setUp();
    return app;
  }

  Future setUp([_]) {
    return runZoned(() {
      return super.setUpWithConfig(_config);
    }, zoneSpecification: new ZoneSpecification(print: (
        Zone self,
        ZoneDelegate parent,
        Zone zone,
        String line) {
      _io.output(new Output('$line'));
    }));
  }
}

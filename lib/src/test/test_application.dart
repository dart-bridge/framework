part of bridge.test;

class TestApplication extends Application {
  final Config _config;
  BridgeCli _program;
  final _InputOutput _io = new _InputOutput();

  TestApplication(List<Type> serviceProviders, {Map config})
      : _config = new Config(config ?? {}),
        super() {
    _program = new BridgeCli(null, new Shell(_io, _io));

    final Iterable<String> serviceProviderQualifiedNames = serviceProviders
        .map(reflectType)
        .map((TypeMirror m) => m.qualifiedName)
        .map(MirrorSystem.getName);

    _config['app'] ??= {};
    _config['app']['service_providers'] ??= [];
    _config['app']['service_providers'].addAll(serviceProviderQualifiedNames);
  }

  List<String> get log => _io.log;

  Future execute(String command) async {
    _io.output(await _program.execute(new Input(command)));
  }

  Future setUp() {
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

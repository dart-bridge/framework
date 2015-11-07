part of bridge.http;

class HttpConfig {
  final Config _config;

  HttpConfig(this._config);

  Map<String, dynamic> get server => _config('http.server', {
    'host': host,
    'port': port,
    'public_root': publicRoot,
    'build_root': buildRoot,
  });

  String get host => _config('http.server.host', 'localhost');
  int get port => _config('http.server.port', 1337);
  String get publicRoot => _config('http.server.public_root', 'web');
  String get buildRoot => _config('http.server.build_root', 'storage/.build');
}

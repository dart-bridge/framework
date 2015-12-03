part of bridge.http;

class HttpConfig {
  final Config _config;

  HttpConfig(this._config);

  Map<String, dynamic> get server => _config('http.server', {
    'host': host,
    'port': port,
    'public_root': publicRoot,
    'build_root': buildRoot,
    'use_ssl': useSsl,
    'ssl': ssl,
  });

  Map<String, String> get ssl => _config('http.server.ssl', {
    'certificate': certificate,
    'private_key': privateKey,
    'password': privateKeyPassword,
  });

  String get certificate => _config('http.server.ssl.certificate');
  String get privateKey => _config('http.server.ssl.private_key');
  String get privateKeyPassword => _config('http.server.ssl.password');
  bool get useSsl => _config('http.server.use_ssl', false);
  String get host => _config('http.server.host', 'localhost');
  int get port => _config('http.server.port', 1337);
  String get publicRoot => _config('http.server.public_root', 'web');
  String get buildRoot => _config('http.server.build_root', 'storage/.build');
}

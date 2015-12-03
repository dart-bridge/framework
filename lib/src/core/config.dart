part of bridge.core;

/// Loads a deep folder structure with YAML-files and its values
/// as a single map with dot-notation accessing.
abstract class Config {
  factory Config(Map<String, Map<String, dynamic>> data) => new _Config(data);
  factory Config.empty() => new Config({});

  /// Gets a value from this config map. Supports dot notation:
  ///
  ///     config['dir']['file']['key'] == config['dir.file.key']; // true
  operator [](String key);

  /// Sets a value to this loaded map, supporting dot notation.
  ///
  /// **NOTE:** This does not change the files loaded, meaning the
  /// changes will not be persisted after the application has
  /// closed. Use this only for runtime configuration.
  void operator []=(String key, value);

  /// Loads all the YAML-files in a directory, recursively, and turns it
  /// into a new config instance. Since this reads from the disk, it is
  /// asynchronous and returns a [Future].
  static Future<Config> load(Directory directory) async {
    if (_envHasNotBeenLoaded() && await _envFileIsPresent()) _loadEnv();
    var config = new Config.empty();
    await config._load(directory);
    return config;
  }

  static _envHasNotBeenLoaded() => !_envHasBeenLoaded;

  static Future<bool> _envFileIsPresent() {
    return new File('.env').exists();
  }

  static _loadEnv() {
    try {
      dotenv.load();
    } on FileSystemException {}
    _envHasBeenLoaded = true;
  }

  static bool _envHasBeenLoaded = false;

  /// Get an environment variable from a `.env` file in the root of
  /// you application. Optionally provide a fallback default value.
  String env(String key, [String defaultValue]);

  /// Tries to return the value of a key, but if it doesn't exist, return
  /// the default value provided instead
  call(String key, [defaultValue]);
}

class _Config implements Config {
  final Map _map;

  _Config(this._map);

  operator [](String key) {
    return _itemFromDotPath(key);
  }

  _itemFromDotPath(String key) {
    return _itemFromDotPathSegments(key.split('.'));
  }

  void operator []=(String key, value) {
    var keySegments = key.split('.');
    var lastKey = keySegments.removeLast();

    _itemFromDotPathSegments(keySegments)
      ..[lastKey] = value;
  }

  _itemFromDotPathSegments(List<String> segments) {
    var item = _map;

    try {
      while (segments.isNotEmpty)
        item = _childOfItemByKey(item, segments.removeAt(0));
    } on NoSuchMethodError {
      return null;
    }

    return item;
  }

  _childOfItemByKey(item, key) {
    return (item is Iterable)
        ? item[int.parse(key)]
        : item[key];
  }

  String toString() {
    return 'Config(${_map})';
  }

  Future _load(Directory directory) async {
    await _throwIfDirectoryDoesNotExist(directory);

    await for (var entity in directory.list(recursive: true))
      if (_isYamlFile(entity))
        await _loadFile(entity, directory);
  }

  Future _throwIfDirectoryDoesNotExist(Directory directory) async {
    if (await _directoryDoesNotExist(directory))
      throw new ConfigException('${directory.path} is not a directory!');
  }

  Future<bool> _directoryDoesNotExist(Directory directory) async {
    return !(await directory.exists());
  }

  _isYamlFile(FileSystemEntity entity) {
    return entity.path.endsWith('.yaml');
  }

  Future _loadFile(File file, Directory root) async {
    this[_makePathOfFile(file, root)] = await _loadYaml(file);
  }

  String _makePathOfFile(File file, Directory root) {
    return file.path
        .replaceAll(new RegExp('^${root.path}\\${Platform.pathSeparator}'), '')
        .replaceAll(new RegExp(r'.yaml$'), '')
        .replaceAll('/', '.');
  }

  Future<dynamic> _loadYaml(File file) async {
    var loaded = yaml.loadYaml(await file.readAsString());

    if (loaded == null) return null;

    if (loaded is Iterable)
      return _replaceEnvInList(new List.from(loaded));

    return _replaceEnvInMap(new Map.from(loaded));
  }

  List _replaceEnvInList(List list) {
    list = list.toList();
    for (var item in list) {
      list[list.indexOf(item)] = _replaceEnv(item);
    }
    return list;
  }

  Map _replaceEnvInMap(Map map) {
    map = new Map.from(map);
    for (var key in map.keys) {
      map[key] = _replaceEnv(map[key]);
    }
    return map;
  }

  Object _replaceEnv(value) {
    if (value is List) return _replaceEnvInList(value);
    if (value is Map) return _replaceEnvInMap(value);
    var matcher = new RegExp(r'^env\(\s*(.*?)\s*(?:,\s*(.*?))?\s*\)$');
    if (value is! String || !matcher.hasMatch(value)) return value;
    final m = matcher.firstMatch(value);
    var envName = m[1];
    var defaultValue = m[2];
    return _cast(env(envName, defaultValue) ?? 'null');
  }

  Object _cast(String env) {
    if (env == 'null') return null;
    if (env == 'true') return true;
    if (env == 'false') return false;
    if (new RegExp(r'^\d+|\d*\.\d+$').hasMatch(env)) return num.parse(env);
    return env;
  }

  call(String key, [defaultValue]) {
    var value = this[key];
    return (value == null) ? defaultValue : value;
  }

  String env(String key, [String defaultValue]) {
    if (_envVariableExists(key)) return dotenv.env[key];
    return defaultValue;
  }

  bool _envVariableExists(String key) {
    return dotenv.env.containsKey(key);
  }
}
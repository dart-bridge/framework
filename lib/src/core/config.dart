part of bridge.core;

/// Loads a deep folder structure with YAML-files and its values
/// as a single map with dot-notation accessing.
abstract class Config {

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

    Config config = new _Config();

    await for (FileSystemEntity entity in directory.list(recursive: true)) {

      FileStat stat = await entity.stat();

      if (!entity.path.endsWith('.yaml')) continue;

      String path = entity.path
      .replaceAll(new RegExp('^${directory.path}/'), '')
      .replaceAll(new RegExp(r'.yaml$'), '')
      .replaceAll('/','.');

      if (stat.type == FileSystemEntityType.DIRECTORY) {

        config[path] = {};
        continue;
      }

      if (stat.type != FileSystemEntityType.FILE) continue;

      File file = entity;

      config[path] = yaml.loadYaml(await file.readAsString());
    }

    return config;
  }
}

class _Config implements Config {

  Map _map = {};

  operator [](String key) {

    var keySegments = key.split('.');

    var pointer = _map;

    while (keySegments.isNotEmpty) {

      var segment = keySegments.removeAt(0);

      pointer = pointer[segment];
    }
    return pointer;
  }

  void operator []=(String key, value) {

    var keySegments = key.split('.');

    var pointer = _map;

    while (keySegments.length > 1) {

      var segment = keySegments.removeAt(0);

      if (!pointer.containsKey(segment)) pointer[segment] = {};

      pointer = pointer[segment];
    }
    pointer[keySegments.removeLast()] = value;
  }

  String toString() {

    return 'Config(${_map})';
  }
}
part of bridge.core;

class Environment {
  static const development = 0;
  static const production = 1;
  static const testing = 2;
  static const custom = 3;
  static int current = production;

  static BridgeInfo _bridge;
  static BridgeInfo get bridge => _bridge;

  static bool get isDevelopment => current == development;
  static bool get isProduction => current == production;
  static bool get isTesting => current == testing;

  static Future loadPubSpec() async {
      final packagesFilePath = path.join(Directory.current.path, '.packages');
      final packagesFile = new File(packagesFilePath);
      final lines = await packagesFile.readAsLines();
      const bridgeIdentifier = 'bridge:';
      final bridgeLine = lines.firstWhere((l) => l.startsWith(bridgeIdentifier));
      final bridgePackagePath = bridgeLine
          .substring(bridgeIdentifier.length)
          .replaceFirst(new RegExp(r'lib/?\\?$'), 'pubspec.yaml');
      final bridgePackage = new File.fromUri(Uri.parse(bridgePackagePath));
      Environment._bridge = new BridgeInfo._(yaml.loadYaml(await bridgePackage.readAsString()));
  }
}

class BridgeInfo {
  Map _pubspec;

  BridgeInfo._(Map this._pubspec);

  String get version => _pubspec['version'];
}

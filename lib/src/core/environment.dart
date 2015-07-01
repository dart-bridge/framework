part of bridge.core;

class Environment {
  static const development = 0;
  static const production = 1;
  static const testing = 2;
  static const custom = 3;
  static int current = production;

  static bool get isDevelopment => current == development;
  static bool get isProduction => current == production;
  static bool get isTesting => current == testing;
}

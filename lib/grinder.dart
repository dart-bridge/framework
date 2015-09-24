library bridge.grinder;

/// This library wraps the CLI in a minimal API for use in Grinder tasks.
///
///     // tool/grind.dart
///
///     // Load all the service provider declarations
///     export '../bridge';
///
///     // Load [bridge.grinder]
///     import 'package:bridge/grinder.dart';
///
///     // Load the regular Grinder things
///     import 'package:grinder/grinder.dart';
///     main(args) => grind(args);
///
///     // Example usage
///     @Task()
///     db_migrate() => bridgeCommand('db_migrate');

import 'dart:async';
import 'package:bridge/cli.dart';

Future bridgeCommand(String command) {
  final args = '$command, exit'.split(' ');
  return new BridgeCli(args, 'config').run(args);
}

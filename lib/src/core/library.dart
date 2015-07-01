/// **Bridge Core Library**
///
/// This library contains the essential parts of the framework,
/// and enabled the extension features, like [ServiceProvider]s,
/// dependency injection and method injection.
library bridge.core;

// Core libraries
import 'dart:mirrors';
import 'dart:io';
import 'dart:async';

// Using
import 'package:bridge/exceptions.dart';
//import 'package:bridge/bridge.dart';

// External libraries
import 'package:yaml/yaml.dart' as yaml;
import 'package:dotenv/dotenv.dart' as dotenv;

part 'application.dart';
part 'container.dart';
part 'config.dart';
part 'config_exception.dart';
part 'container_exception.dart';
part 'service_provider.dart';
part 'environment.dart';
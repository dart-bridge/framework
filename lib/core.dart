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

part 'src/core/application.dart';
part 'src/core/container.dart';
part 'src/core/config.dart';
part 'src/core/config_exception.dart';
part 'src/core/container_exception.dart';
part 'src/core/service_provider.dart';
part 'src/core/environment.dart';
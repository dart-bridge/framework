/// **Bridge Core Library**
///
/// This library contains the essential parts of the framework,
/// and enabled the extension features, like [ServiceProvider]s,
/// dependency injection and method injection.
library bridge.core;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:bridge/exceptions.dart';
import 'package:container/container.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

export 'package:container/container.dart';

part 'src/core/application.dart';
part 'src/core/config.dart';
part 'src/core/config_exception.dart';
part 'src/core/environment.dart';
part 'src/core/service_provider.dart';

library bridge.database;

// Core libraries
import 'dart:mirrors';
import 'dart:async';

// Server side
//import 'package:bridge/bridge.dart';
import 'package:bridge/core.dart';

// Drivers
export 'mongodb/library.dart';

part 'database_service_provider.dart';
part 'repository.dart';
part 'database.dart';
part 'collection.dart';
part 'is.dart';
part 'selector.dart';

const field = 'field';
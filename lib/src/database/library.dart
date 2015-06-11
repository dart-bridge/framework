library bridge.database;

// Core libraries
import 'dart:mirrors';
import 'dart:async';

// Server side
//import 'package:bridge/bridge.dart';
import 'package:bridge/core.dart';

// Drivers
import 'mongodb/library.dart';
export 'mongodb/library.dart';
export 'in_memory/library.dart';

part 'database_service_provider.dart';
part 'repository.dart';
part 'database.dart';
part 'collection.dart';
part 'selector.dart';
part 'model.dart';

const field = 'field';
const key = 'key';

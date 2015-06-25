library bridge.view;
import 'dart:async';
import 'package:plato/plato.dart' as plato;
import 'dart:mirrors';
import 'package:bridge/core.dart';
import 'package:bridge/cli.dart';
import 'dart:io';
import 'package:path/path.dart' show basename, extension;
import 'package:bridge/exceptions.dart';

part 'template_processor.dart';
part 'template_collection.dart';
part 'template_pre_processor.dart';
part 'view_service_provider.dart';
part 'helpers.dart';

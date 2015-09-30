library bridge.view;
import 'dart:async';
import 'package:plato/plato.dart' as plato;
import 'dart:mirrors';
import 'package:bridge/core.dart';
import 'package:bridge/cli.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' show basename, extension;
import 'package:bridge/exceptions.dart';
import 'package:jaded/jaded.dart' as jade;
import 'package:markdown/markdown.dart' as markdown;
import 'dart:convert' show UTF8, HtmlEscape;
import 'package:bridge/http.dart';

import 'view_shared.dart';
export 'view_shared.dart';

part 'src/view/template_processor.dart';
part 'src/view/template_collection.dart';
part 'src/view/template_pre_processor.dart';
part 'src/view/view_service_provider.dart';
part 'src/view/helpers.dart';
part 'src/view/bridge_pre_processor.dart';
part 'src/view/jade_pre_processor.dart';
part 'src/view/markdown_pre_processor.dart';
part 'src/view/handlebars_pre_processor.dart';

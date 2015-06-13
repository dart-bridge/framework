library bridge.view;

// Core libraries
import 'dart:io';
import 'dart:async';
import 'dart:convert';

// Using
import 'package:bridge/core.dart';
import 'package:bridge/http.dart';
import 'package:bridge/exceptions.dart';
import 'package:bridge/cli.dart';

part 'exceptions/template_exception.dart';
part 'view_service_provider.dart';
part 'template_response.dart';
part 'helpers.dart';
part 'template_loader.dart';
part 'file_template_loader.dart';
part 'template.dart';
part 'template_parser.dart';
part 'btl_parser.dart';
part 'btl_to_handlebars_parser.dart';

var _templateParsers = <String, Type>{
  'html': BtlParser,
  'handlebars': BtlToHandlebarsParser,
};

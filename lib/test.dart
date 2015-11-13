library bridge.test;

import 'dart:mirrors';
import 'dart:async';

import 'package:test/test.dart';

import 'core.dart';
import 'cli.dart';

part 'src/test/test_application.dart';
part 'src/test/input_output.dart';

TestApplication testApp(List<Type> serviceProviders, {Map config}) {
  Environment.current = Environment.testing;
  final app = new TestApplication(serviceProviders, config: config);
  setUpAll(app.setUp);
  tearDownAll(app.setUp);
  return app;
}

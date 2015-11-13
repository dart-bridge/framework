library test.test.test_application_test;

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/test.dart';
import 'package:bridge/core.dart';

class TestApplicationTest implements TestCase {
  TestApplication app;

  TestApplicationTest() {
    app = testApp([
      TestServiceProvider
    ]);
  }

  setUp() {}

  tearDown() {}

  @test
  it_correctly_encapsulates_service_providers() {
    expect(app.log, contains('something'));
  }
}

class TestServiceProvider extends ServiceProvider {
  setUp() {
    print('something');
  }
}


library test.test.test_application_test;

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/test.dart';
import 'package:bridge/core.dart';
import 'package:bridge/cli.dart';

class TestApplicationTest implements TestCase {
  TestApplication app;

  setUp() async {
    app = await TestApplication.start([
      TestServiceProvider
    ]);
  }

  tearDown() async {
    await app.tearDown();
  }

  @test
  it_correctly_encapsulates_service_providers() {
    expect(app.log, contains('something'));
  }

  @test
  it_can_have_entire_lifecycle_in_test_scope() async {
    final app = await TestApplication.start([TestServiceProvider]);
    expect(app.log, contains('something'));
    await app.tearDown();
  }

  @test
  it_has_correctly_set_up_the_container() {
    expect(app.make(MyInterface), new isInstanceOf<MyImplementation>());
  }

  @test
  it_has_an_interface_for_the_cli() async {
    await app.execute('test_command 3');
    final TestServiceProvider serviceProvider = app.serviceProviders.first;
    serviceProvider.expectTestCommandWasRun();
  }
}

abstract class MyInterface {}
class MyImplementation implements MyInterface {}

class TestServiceProvider extends ServiceProvider {
  bool _testCommandWasRun = false;

  setUp(Container container) {
    container.bind(MyInterface, MyImplementation);
    print('something');
  }

  load(Program program) {
    program.addCommand(test_command);
  }

  @Command('_')
  test_command(@Option('_') int option) {
    expect(option, new isInstanceOf<int>());
    _testCommandWasRun = true;
  }

  void expectTestCommandWasRun() {
    expect(_testCommandWasRun, isTrue, reason: 'test_command was never called');
  }
}


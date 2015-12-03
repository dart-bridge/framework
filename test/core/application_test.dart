library bridge.core.application_test;

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';

class ApplicationTest implements TestCase {
  Application application;
  Config config;

  setUp() {
    config = new Config({
      'app': {}
    });
    application = new Application();
  }

  tearDown() {}

  @test
  it_contains_a_list_of_service_providers() async {
    config['app.service_providers'] = [
      'bridge.core.application_test.FirstServiceProvider',
    ];

    await application.setUpWithConfig(config);

    expect(application.serviceProviders.length, equals(1));
    expect(application.serviceProviders[0],
        new isInstanceOf<FirstServiceProvider>());
    expect(application.hasServiceProvider(FirstServiceProvider), isTrue);
  }

  @test
  it_throws_when_a_service_provider_depends_on_one_thats_not_included() async {
    config['app.service_providers'] = [
      'bridge.core.application_test.SecondServiceProvider',
    ];

    expect(application.setUpWithConfig(config),
        throwsA(new isInstanceOf<MissingDependencyException>()));
  }

  @test
  it_doesnt_throw_when_the_dependency_is_not_strict() async {
    config['app.service_providers'] = [
      'bridge.core.application_test.ThirdServiceProvider',
    ];

    await application.setUpWithConfig(config);
  }

  @test
  it_doesnt_throw_if_all_dependencies_are_included() async {
    config['app.service_providers'] = [
      'bridge.core.application_test.ThirdServiceProvider',
      'bridge.core.application_test.SecondServiceProvider',
      'bridge.core.application_test.FirstServiceProvider',
    ];

    await application.setUpWithConfig(config);
  }
}

class FirstServiceProvider extends ServiceProvider {}

@DependsOn(FirstServiceProvider)
class SecondServiceProvider extends ServiceProvider {}

@DependsOn(SecondServiceProvider, strict: false)
class ThirdServiceProvider extends ServiceProvider {}

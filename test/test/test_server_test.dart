library test.test.test_server_test;

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/test.dart';
import 'package:bridge/core.dart';
import 'package:bridge/http.dart';

class TestServerTest implements TestCase {
  TestApplication app;

  setUp() async {
    app = await TestApplication.start([
      HttpServiceProvider,
      TestPipelineServiceProvider,
    ]);
  }

  tearDown() async {
    await app.tearDown();
  }

  @test
  it_can_make_a_request() async {
    expect(await app.server
        .get('/')
        .body, 'x');
  }

  @test
  it_supports_middleware() async {
    expect(await app.server
        .get('i', {'k': 'v'})
        .body, '{"k":"v"}');
  }

  @test
  it_supports_error_handlers() async {
    expect(await app.server
        .get('e')
        .body, 'y');
  }
}

class TestPipelineServiceProvider extends ServiceProvider {
  load(Router router, Container container) {
    router.get('/', () => 'x');
    router.get('i', (Input input) => input);
    router.get('e', () => throw '');

    container.bind(Pipeline, TestPipeline);
  }
}

class TestPipeline extends Pipeline {
  @override get middleware => [
    InputMiddleware
  ];

  @override get errorHandlers => {
    Object: () => 'y',
  };
}

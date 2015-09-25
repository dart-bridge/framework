library bridge.http;

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'dart:mirrors';

part 'packages/bridge/src/http/router.dart';
part 'packages/bridge/src/http/route.dart';

class RouterTest implements TestCase {
  Router router;

  setUp() {
    router = new Router();
  }

  tearDown() {}

  void expectRoutes(List<Route> routes) {
    final expectedRoutes = routes.toList();
    for (final registeredRoute in router._routes) {
      final expectedRoute = expectedRoutes.removeAt(0);
      expect(registeredRoute.method, equals(expectedRoute.method));
      expect(registeredRoute.route, equals(expectedRoute.route));
      expect(registeredRoute.name, equals(expectedRoute.name));
      expect(registeredRoute.handler, equals(expectedRoute.handler));
    }
  }

  @test
  it_contains_routes() {
    router.get('/', emptyHandler);

    expectRoutes([
      new Route('GET', '/', emptyHandler)
    ]);
  }

  @test
  it_has_methods_corresponding_to_http() {
    router.get('/', emptyHandler);
    router.post('/', emptyHandler);
    router.put('/', emptyHandler);
    router.update('/', emptyHandler);
    router.patch('/', emptyHandler);
    router.delete('/', emptyHandler);

    expectRoutes([
      new Route('GET', '/', emptyHandler),
      new Route('POST', '/', emptyHandler),
      new Route('PUT', '/', emptyHandler),
      new Route('UPDATE', '/', emptyHandler),
      new Route('PATCH', '/', emptyHandler),
      new Route('DELETE', '/', emptyHandler),
    ]);
  }

  @test
  it_has_a_restful_batch_method() {
    final controller = new CompleteResourceController();
    router.resource('test', controller);

    expectRoutes([
      new Route('GET', 'test', controller.index, name: 'test.index'),
      new Route('GET', 'test/create', controller.create, name: 'test.create'),
      new Route('POST', 'test', controller.store, name: 'test.store'),
      new Route('GET', 'test/:id', controller.show, name: 'test.show'),
      new Route('GET', 'test/:id/edit', controller.edit, name: 'test.edit'),
      new Route('PUT', 'test/:id', controller.update, name: 'test.update'),
      new Route('DELETE', 'test/:id', controller.destroy, name: 'test.destroy'),
    ]);
  }

  @test
  it_supports_partial_resources() {
    final controller = new PartialResourceController();
    router.resource('test', controller);

    expectRoutes([
      new Route('GET', 'test', controller.index, name: 'test.index'),
      new Route('GET', 'test/create', controller.create, name: 'test.create'),
      new Route('DELETE', 'test/:id', controller.destroy, name: 'test.destroy'),
    ]);
  }

  @test
  it_can_attach_a_name() {
    router.get('/', emptyHandler)
        .named('name');

    expectRoutes([
      new Route('GET', '/', emptyHandler, name: 'name')
    ]);
  }

  @test
  it_can_attach_injecting_objects() {
    final someString = 'content';

    router.get('/', emptyHandler)
        .inject(someString);

    expect(router._routes.first._shouldInject, equals({
      String: someString
    }));
  }

  @test
  it_can_attach_injection_of_supertype() {
    final subClass = new SubClass();

    router.get('/', emptyHandler)
        .inject(subClass, as: BaseClass);

    expect(router._routes.first._shouldInject, equals({
      BaseClass: subClass
    }));
  }
}

class BaseClass {
}

class SubClass extends BaseClass {
}

void emptyHandler() => null;

class CompleteResourceController {
  index() {}

  create() {}

  store() {}

  show() {}

  edit() {}

  update() {}

  destroy() {}
}

class PartialResourceController {
  index() {}

  create() {}

  destroy() {}
}

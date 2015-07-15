import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';
import 'package:bridge/core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'dart:async';

class MiddlewareTest implements TestCase {
  Container container;

  setUp() {
    container = new Container();
  }

  tearDown() {}

  @test
  it_always_contains_a_shelf_middleware() {
    expect(
        new RequestMiddleware().transform(container),
        new isInstanceOf<shelf.Middleware>());
  }

  Future expectResponseBody(Middleware middleware, String body) async {
    shelf.Middleware shelfMiddleware = middleware.transform(container);
    shelf.Response response = await shelfMiddleware((innerHandler) {
      return new shelf.Response.ok('pass through');
    })(new shelf.Request('GET', new Uri.http('localhost', '/path')));
    String responseBody = await response.readAsString();
    expect(responseBody, equals(body));
  }

  @test
  it_can_be_a_request_middleware_that_does_nothing() async {
    await expectResponseBody(new RequestMiddlewareThatDoesNothing(), 'pass through');
  }

  @test
  it_can_be_a_request_middleware_with_dependencies() async {
    await expectResponseBody(new RequestMiddleware(), 'some external value');
  }

  @test
  it_can_be_a_response_middleware_that_does_nothing() async {
    await expectResponseBody(new ResponseMiddlewareThatDoesNothing(), 'pass through');
  }

  @test
  it_can_be_a_response_middleware_with_dependencies() async {
    await expectResponseBody(new ResponseMiddleware(), 'some external value');
  }

  @test
  it_can_be_both() async {
    var mock = new MockRequestResponseMiddleware();
    await expectResponseBody(mock, 'some new value');
    mock.verifyBothCalled();
  }
}

class RequestMiddlewareThatDoesNothing extends Middleware {
  request() {}
}

class Dependency {
  String value = 'some external value';
}

class RequestMiddleware extends Middleware {
  request(Dependency dependency) {
    return dependency.value;
  }
}

class ResponseMiddlewareThatDoesNothing extends Middleware {
  response() {}
}

class ResponseMiddleware extends Middleware {
  response(Dependency dependency) {
    return dependency.value;
  }
}

class MockRequestResponseMiddleware extends Middleware {
  bool _requestCalled = false;
  bool _responseCalled = false;

  request(shelf.Request request) {
    _requestCalled = true;
    expect(request.url.path, equals('path'));
  }

  response(shelf.Response response) async {
    _responseCalled = true;
    expect(await response.readAsString(), equals('pass through'));
    return 'some new value';
  }

  void verifyBothCalled() {
    expect(_requestCalled, isTrue, reason: 'The middleware never received a request');
    expect(_responseCalled, isTrue, reason: 'The middleware never received a response');
  }
}
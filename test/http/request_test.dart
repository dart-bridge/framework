import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'package:bridge/http.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'dart:convert';

class RequestTest implements TestCase {
  Router router;
  Server server;
  Config config;
  Container container;

  setUp() {
    config = new Config();
    container = new Container();
    router = new Router();
    server = new Server(config, container);
    server.attachRouter(router);
  }

  tearDown() {
  }

  @test
  it_handles_requests() async {
    router.get('/', () {
      return 'response';
    });
    var request = new shelf.Request('GET', new Uri.http('example.com', '/'));
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(), equals('response'));
  }

  @test
  it_can_simulate_a_put_request() async {
    router.put('/', () {
      return 'response';
    });
    var request = new shelf.Request(
        'POST',
        new Uri.http('example.com', '/'),
        body: JSON.encode({
          '_method': 'PUT'
        }),
        headers: {
          'Content-Type': 'application/json'
        });
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(), equals('response'));
  }
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'package:bridge/http.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'dart:convert';
import 'package:shelf/src/message.dart' as shelf;

class RequestTest implements TestCase {
  Router router;
  Server server;
  Config config;
  Container container;
  Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json'
  };
  Map<String, String> textHeaders = {
    'Content-Type': 'text/plain'
  };
  MockSessionManager sessions;

  setUp() {
    config = new Config();
    container = new Container();
    router = new Router();
    sessions = new MockSessionManager();
    server = new Server(config, container)
      ..attachRouter(router)
      ..addMiddleware(new SessionsMiddleware(sessions))..addMiddleware(
          new InputMiddleware());
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
          '_method': 'PUT',
        }),
        headers: jsonHeaders);
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(), equals('response'));
  }

  @test
  it_protects_against_csrf() async {
    server.addMiddleware(new CsrfMiddleware());
    router.post('/', (Input input) {
      return input['key'];
    });
    var method = 'POST';
    var uri = new Uri.http('example.com', '/');
    var body = {
      'key': 'value'
    };
    var request = new shelf.Request(
        method,
        uri,
        body: JSON.encode(body),
        headers: jsonHeaders);

    shelf.Response failedResponse = await server.handle(request);
    expect(await failedResponse.readAsString(), isNot(equals('value')));

    request = new shelf.Request(
        method,
        uri,
        body: JSON.encode(body
          ..addAll({'_token': 'id'})),
        headers: jsonHeaders);

    shelf.Response successfulResponse = await server.handle(request);
    expect(await successfulResponse.readAsString(), equals('value'));
  }

  @test
  it_injects_a_hidden_input_in_html_forms_with_csrf_token() async {
    server.addMiddleware(new CsrfMiddleware());
    sessions.returningSession = new Session('id');
    router.get('/', () => '<form></form>');
    var request = new shelf.Request('GET', new Uri.http('example.com', '/'));
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(),
        equals("<form><input type='hidden' name='_token' value='id'></form>"));
  }

  @test
  it_can_add_specific_middleware_for_a_route() async {
    router.post('/', () => 'response')
        .withMiddleware(CsrfMiddleware);
    var request = new shelf.Request(
        'POST', new Uri.http('example.com', '/'), headers: textHeaders);
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(), equals('Token mismatch'));
  }

  @test
  it_can_ignore_specific_middleware_for_a_route() async {
    server.addMiddleware(new CsrfMiddleware());
    router.post('/', () => 'response')
        .ignoreMiddleware(CsrfMiddleware);
    var request = new shelf.Request(
        'POST', new Uri.http('example.com', '/'), headers: textHeaders);
    shelf.Response response = await server.handle(request);
    expect(await response.readAsString(), equals('response'));
  }

  @test
  it_injects_the_dependencies_of_the_route() async {
    router.get('/', (String input) => input).inject('injected');
    final request = new shelf.Request('GET', new Uri.http('example.com', '/'));
    final response = await server.handle(request);
    expect(await response.readAsString(), equals('injected'));
  }
}

class MockSessionManager implements SessionManager {
  Session returningSession = new Session('id');

  shelf.Message attachSession(shelf.Message message) {
    return message.change(context: {
      'session': returningSession
    });
  }

  void close(String id) {
    // TODO: implement close
  }

  bool hasSession(shelf.Message message) {
    return true;
  }

  void open(String id) {
    // TODO: implement open
  }

  shelf.Message passSession({shelf.Message from, shelf.Message to}) {
    return to.change(context: {'session': from.context['session']});
  }

  Session session(String id) {
    return returningSession;
  }

  Session sessionOf(shelf.Message message) {
    return returningSession;
  }
}
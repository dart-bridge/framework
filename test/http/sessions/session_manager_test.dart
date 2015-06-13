import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';
import 'package:shelf/shelf.dart' as shelf;

class SessionManagerTest implements TestCase {
  SessionManager manager;

  setUp() {
    manager = new SessionManager();
  }

  tearDown() {
  }

  @test
  it_manages_sessions() {
    manager.open('id');
    expect(manager.session('id').id, equals('id'));
    manager.close('id');
    expect(manager.session('id'), isNull);
  }

  @test
  it_couples_a_shelf_request_with_a_session() {
    var request = new shelf.Request('GET', new Uri.http('example.com', '/'));
    expect(manager.hasSession(request), isFalse);
    request = manager.attachSession(request);
    var session = manager.sessionOf(request);
    expect(session, new isInstanceOf<Session>());
    expect(manager.sessionOf(request), equals(session));
  }

  @test
  it_passes_a_request_session_to_a_response() {
    var request = manager.attachSession(
        new shelf.Request('GET', new Uri.http('example.com', '/')));
    var response = manager.passSession(from: request, to: new shelf.Response.ok('body'));

    expect(manager.sessionOf(request), equals(manager.sessionOf(response)));
  }
}

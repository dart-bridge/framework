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
    final request = new shelf.Request('GET', new Uri.http('example.com', '/'));
    expect(manager.hasSession(request), isFalse);
    final session = manager.attachSession(request);
    expect(session, new isInstanceOf<Session>());
  }
}

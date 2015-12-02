import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';

class RouteTest implements TestCase {
  final Function handler = () {};

  setUp() {}

  tearDown() {}

  @test
  it_contains_a_url_route_and_value() {
    final route = new Route('GET', '/', handler);
    expect(route.method, equals('GET'));
    expect(route.route, equals('/'));
    expect(route.handler, equals(handler));
  }

  @test
  it_matches_an_input_uri_to_the_route() {
    final a = new Route('GET', '/', handler);
    expect(a.matches('GET', '/'), isTrue);
    expect(a.matches('GET', ''), isTrue);
    expect(a.matches('GET', '/no'), isFalse);

    final b = new Route('GET', '/:wildcard', handler);
    expect(b.matches('GET', '/value'), isTrue);
    expect(b.matches('GET', ''), isFalse);
    expect(b.matches('GET', '/'), isFalse);

    final c = new Route('GET', ':wildcard', handler);
    expect(c.matches('GET', '/value'), isTrue);
    expect(c.matches('GET', 'value'), isTrue);
    expect(c.matches('GET', ''), isFalse);
    expect(c.matches('GET', '/'), isFalse);
  }

  @test
  it_can_have_wildcards() {
    final route = new Route('GET', 'path/:wildcard', handler);
    expect(route.matches('GET', '/path/id'), isTrue);
  }

  @test
  it_can_make_a_map_of_wildcard_values() {
    final route = new Route('GET', 'path/:wildcard1/:wildcard2', handler);
    expect(route.wildcards('/path/value1/value2'), equals({
      'wildcard1': 'value1',
      'wildcard2': 'value2',
    }));
  }

  @test
  it_can_optionally_have_a_name() {
    final route = new Route('GET', '/', handler, name: 'home');
    expect(route.name, equals('home'));
  }

  @test
  it_allows_head_requests_to_access_get_routes() async {
    final route = new Route('GET', '/', handler);
    expect(route.matches('HEAD', '/'), isTrue);
  }
}
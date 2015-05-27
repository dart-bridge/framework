import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';

class RouteTest implements TestCase {

  final Function handler = () {};

  setUp() {}

  tearDown() {}

  @test
  it_contains_a_url_route_and_value() {
    var route = new Route('GET', '/', handler);
    expect(route.method, equals('GET'));
    expect(route.route, equals('/'));
    expect(route.handler, equals(handler));
  }

  @test
  it_matches_an_input_uri_to_the_route() {
    var route = new Route('GET', '/', handler);
    expect(route.matches('GET', '/'), isTrue);
    expect(route.matches('GET', ''), isTrue);
    expect(route.matches('GET', '/no'), isFalse);
    route = new Route('GET', '/:wildcard', handler);
    expect(route.matches('GET', '/value'), isTrue);
    expect(route.matches('GET', ''), isFalse);
    expect(route.matches('GET', '/'), isFalse);
    route = new Route('GET', ':wildcard', handler);
    expect(route.matches('GET', '/value'), isTrue);
    expect(route.matches('GET', 'value'), isTrue);
    expect(route.matches('GET', ''), isFalse);
    expect(route.matches('GET', '/'), isFalse);
  }

  @test
  it_can_have_wildcards() {
    var route = new Route('GET', 'path/:wildcard', handler);
    expect(route.matches('GET', '/path/id'), isTrue);
  }

  @test
  it_can_make_a_map_of_wildcard_values() {
    var route = new Route('GET', 'path/:wildcard1/:wildcard2', handler);
    expect(route.wildcards('/path/value1/value2'), equals({
      'wildcard1': 'value1',
      'wildcard2': 'value2',
    }));
  }
}

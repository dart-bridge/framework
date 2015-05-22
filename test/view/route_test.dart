import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';

class RouteTest implements TestCase {

  setUp() {}

  tearDown() {}

  @test
  it_contains_a_url_route_and_value() {
    var route = const Route('GET', '/', 'value');
    expect(route.method, equals('GET'));
    expect(route.route, equals('/'));
    expect(route.value, equals('value'));
  }

  @test
  it_matches_an_input_uri_to_the_route() {
    var route = const Route('GET', '/path', 'value');
    expect(route.matches('GET', '/path'), isTrue);
    expect(route.matches('GET', 'path'), isTrue);
  }

  @test
  it_can_have_wildcards() {
    var route = const Route('GET', 'path/:wildcard', 'value');
    expect(route.matches('GET', '/path/id'), isTrue);
  }

  @test
  it_can_make_a_map_of_wildcard_values() {
    var route = const Route('GET', 'path/:wildcard1/:wildcard2', 'value');
    expect(route.wildcards('/path/value1/value2'), equals({
      'wildcard1': 'value1',
      'wildcard2': 'value2',
    }));
  }
}

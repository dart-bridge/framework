import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

class RouterTest implements TestCase {

  Router router;

  setUp() {
    router = new Router();
  }

  tearDown() {}

  @test
  it_registers_routes_and_compares_it_with_input() {
    router.route('GET', 'test', 'identifier');
    expect(router.match('GET', 'test').value, equals('identifier'));
  }

  @test
  it_throws_exception_if_no_route_matches_input() {
    expect(() => router.match('GET', 'anything'), throws);
  }

  @test
  it_throws_when_methods_differ() {
    router.route('GET', 'test', 'identifier');
    expect(() => router.match('POST', 'test'), throws);
  }

  @test
  it_has_a_shorthand_syntax_for_get_requests() {
    router.get('test', 'identifier');
    expect(router.match('GET', 'test').value, equals('identifier'));
  }

  @test
  it_has_a_shorthand_syntax_for_post_requests() {
    router.post('test', 'identifier');
    expect(router.match('POST', 'test').value, equals('identifier'));
  }
}

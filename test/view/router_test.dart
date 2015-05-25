import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';

class RouterTest implements TestCase {

  Router router;

  Function handler = () {};

  setUp() {
    router = new Router();
  }

  tearDown() {}

  @test
  it_registers_routes_and_compares_it_with_input() {
    router.route('GET', 'test', handler);
    expect(router.match('GET', 'test').handler, equals(handler));
  }

  @test
  it_throws_exception_if_no_route_matches_input() {
    expect(() => router.match('GET', 'anything'), throws);
  }

  @test
  it_throws_when_methods_differ() {
    router.route('GET', 'test', handler);
    expect(() => router.match('POST', 'test'), throws);
  }

  @test
  it_has_a_shorthand_syntax_for_get_requests() {
    router.get('test', handler);
    expect(router.match('GET', 'test').handler, equals(handler));
  }

  @test
  it_has_a_shorthand_syntax_for_post_requests() {
    router.post('test', handler);
    expect(router.match('POST', 'test').handler, equals(handler));
  }

  @test
  it_has_a_shorthand_for_single_page_applications() {
    router.all(handler);
    expect(router.match('GET', 'anything').handler, equals(handler));
    expect(router.match('GET', 'anything/else').handler, equals(handler));
  }

  @test
  it_registers_a_not_found_handler() {
    router.notFoundHandler = handler;
    expect(router.notFoundHandler, equals(handler));
  }
}

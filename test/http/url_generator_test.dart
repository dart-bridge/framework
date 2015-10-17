import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';

class UrlGeneratorTest implements TestCase {
  UrlGenerator generator;
  Router router;

  setUp() {
    router = new Router();
    generator = new UrlGenerator(router);
  }

  tearDown() {}

  @test
  it_passes_through_a_normal_url() {
    expect(generator.url('pages'), equals('/pages'));
    expect(generator.url('pages//'), equals('/pages'));
    expect(generator.url('pages/sub/'), equals('/pages/sub'));
    expect(generator.url('/pages/sub/'), equals('/pages/sub'));
  }

  @test
  it_can_reference_the_url_of_a_route() {
    router.get('pages/all', () => null).named('pages');
    expect(generator.route('pages'), equals('/pages/all'));
  }

  @test
  it_can_provide_wildcards_to_insert_into_the_route() {
    router.get('pages/:username/:id', () => null).named('page');
    expect(generator.route('page', {'username': 'emil', 'id': 1,}),
        equals('/pages/emil/1'));
  }
}

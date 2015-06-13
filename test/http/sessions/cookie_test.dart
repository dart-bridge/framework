import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';

class CookieTest implements TestCase {
  Cookie cookie;

  setUp() {
    cookie = const Cookie('key', 'value');
  }

  tearDown() {}

  @test
  it_has_a_key_and_a_value() {
    expect(cookie.key, equals('key'));
    expect(cookie.value, equals('value'));
  }

  @test
  it_can_be_loaded_multiple_by_string() {
    var cookies = Cookie.parse('key=value; key2=value2');
    expect(cookies[0].key, equals('key'));
    expect(cookies[1].value, equals('value2'));
  }

  @test
  it_can_be_parsed_into_a_setcookie_header() {
    expect(cookie.set(
        duration: const Duration(hours: 2),
        secure: false,
        httpOnly: true),
    equals('key=value; Path=/; Max-Age=7200; HttpOnly'));
  }
}

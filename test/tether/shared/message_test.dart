import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';

class MessageTest implements TestCase {

  setUp() {}

  tearDown() {}

  @test
  it_can_generate_a_token_of_50_random_characters() {
    expect(Message.generateToken().length, equals(50));
  }
}

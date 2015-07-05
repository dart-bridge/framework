import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';

class MessageTest implements TestCase {

  setUp() {
  }

  tearDown() {
  }

  @test
  it_can_generate_a_token_of_50_random_characters() {
    expect(Message.generateToken().length, equals(50));
  }

  @test
  it_can_serialize_and_deserialize_json() {
    var message = new Message('k', 't', 1, 'rT');
    var json = '{"key":"k","token":"t","data":1,"returnToken":"rT"}';
    expect(message.serialized, equals(json));
    expect(new Message.deserialize(json).serialized, equals(message.serialized));
  }

  @test
  it_generates_a_return_token_if_one_hasnt_been_provided() {
    expect(new Message('k', 't', 1).returnToken.length, equals(50));
  }
}

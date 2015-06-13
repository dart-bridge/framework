import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';
import 'dart:async';

class MessengerTest implements TestCase {
  MockSocket socket;
  Messenger messenger;
  final String exampleJson = '{"key":"k","token":"t","data":1,"returnToken":"rT","structure":null}';
  final Message exampleMessage = new Message('k', 't', 1, 'rT');

  setUp() {
    socket = new MockSocket();
    messenger = new Messenger(socket);
  }

  tearDown() {
  }

  @test
  it_converts_input_json_to_message() async {
    socket.socketInput.add(exampleJson);
    Message message = await messenger.listen('k').first;
    expect(message.key, equals('k'));
    expect(message.token, equals('t'));
    expect(message.data, equals(1));
    expect(message.returnToken, equals('rT'));
  }

  @test
  it_sends_messages_as_json() async {
    messenger.send(exampleMessage);
    await null;
    expect(socket.sentData, equals(exampleJson));
  }

  @test
  it_can_register_serializable_items_that_can_then_be_transfered() async {
    messenger.registerStructure(
        'TestSerializable',
        TestSerializable,
            (d) => new TestSerializable(d['someString']));
    socket.socketInput.add('{"key":"k","token":"t","data":{"someString":"value"},"returnToken":"rT","structure":"TestSerializable"}');
    Message message = await messenger.listen('k').first;
    expect(message.data, new isInstanceOf<TestSerializable>());
    expect(message.data.someString, equals('value'));
  }

  @test
  it_can_send_serializable_items() async {
    messenger.registerStructure(
        'TestSerializable',
        TestSerializable,
            (d) => new TestSerializable(d['someString']));
    messenger.send(new Message('k', 't', new TestSerializable('value'), 'rT'));
    await null;
    expect(socket.sentData, equals('{"key":"k","token":"t","data":{"someString":"value"},"returnToken":"rT","structure":"TestSerializable"}'));
  }
}

class TestSerializable implements Serializable {
  final String someString;

  TestSerializable(String this.someString);

  Object serialize() => {
    'someString': someString
  };
}

class MockSocket implements SocketInterface {
  bool get isOpen => true;

  Future get onOpen => null;

  Future get onClose => null;

  StreamController socketInput = new StreamController();

  Stream get receiver => socketInput.stream;

  void send(data) {
    sentData = data;
  }

  var sentData;
}
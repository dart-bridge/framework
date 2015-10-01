import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';
import 'dart:async';

class TetherTest implements TestCase {
  Tether tether;
  MockMessenger messenger;

  setUp() {
    messenger = new MockMessenger();
    tether = new Tether('token', messenger);
  }

  tearDown() {
  }

  @test
  it_sends_data() async {
    await tether.send('key', 1);
    expect(messenger.sentMessage.key, equals('key'));
    expect(messenger.sentMessage.data, equals(1));
  }

  @test
  it_receives_data() async {
    bool wasCalled = false;
    tether.listen('key', (data) {
      expect(data, equals(1));
      wasCalled = true;
    });
    messenger.messages.add(new Message('key', 'token', 1));
    await null;
    await null;
    await null;
    expect(wasCalled, isTrue);
  }

  @test
  it_requests_data_and_receives_a_response() async {
    var response = await tether.send('key');
    expect(response, equals(1));
  }

  @test
  it_can_register_modulators_of_listener_return_values_before_serialization() async {
    tether.modulateBeforeSerialization((value) {
      if (value == 'value')
        return 'modulatedValue';
      return value;
    });
    await tether.send('key', 'value');
    expect(messenger.sentMessage.key, equals('key'));
    expect(messenger.sentMessage.data, equals('modulatedValue'));
  }
}

class MockMessenger implements Messenger {
  StreamController<Message> messages = new StreamController();

  Stream<Message> listen(String key) {
    if (key == 'key') return messages.stream;
    return new StreamController().stream;
  }

  Future get onConnectionOpen => null;

  Future get onConnectionEnd => null;

  Message sentMessage;

  Future<Message> send(Message message) async {
    sentMessage = message;
    return new Message('k', 't', 1);
  }

  bool get socketIsOpen => true;
}
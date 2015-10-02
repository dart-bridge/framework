import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether_shared.dart';
import 'package:bridge/http_shared.dart';
import 'dart:async';

class TetherTest implements TestCase {
  Tether tether;
  MockMessenger messenger;

  setUp() {
    messenger = new MockMessenger();
    tether = new TestTether(new Session('token'), messenger);
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
    messenger.messages.add(new Message('key', new Session('token'), 1));
    await wait(ticks: 1);
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

  @test
  it_can_receive_data_once() async {
    bool firstWasCalled = false;
    tether.listenOnce('key', (data) {
      expect(data, equals(1));
      firstWasCalled = true;
    });
    messenger.messages.add(new Message('key', new Session('token'), 1));
    await wait(ticks: 3);

    bool secondWasCalled = false;
    tether.listenOnce('key', (data) {
      expect(data, equals(1));
      secondWasCalled = true;
    });
    messenger.messages.add(new Message('key', new Session('token'), 1));
    await wait(ticks: 3);

    expect(firstWasCalled, isTrue);
    expect(secondWasCalled, isTrue);
  }

  Future wait({int ticks}) async {
    for (var tick = 0; tick < ticks; tick++)
      await null;
  }
}

class TestTether extends TetherBase {
  TestTether(Session session, Messenger messenger) : super(session, messenger);

  Future applyData(data, Function listener) async {
    return listener(data);
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
    return new Message('k', new Session('t'), 1);
  }

  bool get socketIsOpen => true;

  void removeListener(String key) {
    messages = new StreamController();
  }
}
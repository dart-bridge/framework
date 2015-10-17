import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';
import 'package:bridge/http.dart';
import 'dart:async';

class MessengerTest implements TestCase {
  MockSocket socket;
  Messenger messenger;
  final String exampleJson = '{'
      '"key":"k",'
      r'"session":{"$$":"Session","$$$":["t",{}]},'
      '"data":1,'
      '"returnToken":"rT"'
      '}';
  final Message exampleMessage = new Message('k', new Session('t'), 1, 'rT');

  setUp() {
    registerTetherTransport();
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
    expect(message.session.id, equals('t'));
    expect(message.data, equals(1));
    expect(message.returnToken, equals('rT'));
  }

  @test
  it_sends_messages_as_json() async {
    messenger.send(exampleMessage);
    await null;
    expect(socket.sentData, equals(exampleJson));
  }
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
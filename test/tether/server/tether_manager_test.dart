import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/bridge.dart';
import 'dart:async';

class TetherManagerTest implements TestCase {

  TetherManager manager;

  setUp() {
    manager = new TetherManager();
  }

  tearDown() {
  }

  @test
  it_registers_a_handler_for_tethers() {
    var mockTether = new MockTether();
    var wasCalled = false;
    manager.registerHandler((Tether tether) {
      expect(tether, equals(mockTether));
      wasCalled = true;
    });
    manager.manage(mockTether);
    expect(wasCalled, isTrue);
  }

  @test
  it_can_have_multiple_handlers() {
    var mockTether = new MockTether();
    var wasCalledFirst = false;
    var wasCalledSecond = false;
    manager.registerHandler((Tether tether) {
      expect(tether, equals(mockTether));
      wasCalledFirst = true;
    });
    manager.registerHandler((Tether tether) {
      expect(tether, equals(mockTether));
      wasCalledSecond = true;
    });
    manager.manage(mockTether);
    expect(wasCalledFirst, isTrue);
    expect(wasCalledSecond, isTrue);
  }

  @test
  it_can_broadcast_messages() async {
    var firstTether = new MockTether();
    var secondTether = new MockTether();
    manager.manage(firstTether);
    manager.manage(secondTether);
    manager.broadcast('_', 'data');
    await null;
    await null;
    expect(firstTether.didSend, equals('data'));
    expect(secondTether.didSend, equals('data'));
  }
}

class MockTether implements Tether {
  var didSend;

  Session get session => null;

  Future get onConnectionLost => null;

  Future get onConnectionEstablished => null;

  Future send(String key, [data]) async => didSend = data;

  StreamSubscription listen(String key, Future listener(data)) => null;

  void initiatePersistentConnection() => null;

  void sendException(String key, Exception exception) {}

  void modulateBeforeSerialization(modulation(value)) {}

  Future applyData(data, Function listener) {
    return listener(data);
  }

  void listenOnce(String key, Function listener) {}
}

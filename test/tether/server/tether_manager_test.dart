import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';
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
}

class MockTether implements Tether {
  String get token => null;

  Future get onConnectionLost => null;

  Future get onConnectionEstablished => null;

  Future send(String key, [data]) => null;

  void listen(String key, Future listener(data)) => null;

  void initiatePersistentConnection() => null;

  void sendException(String key, Exception exception) {
  }

  void registerStructure(String id, Type serializable, Serializable factory(data)) {
  }
}

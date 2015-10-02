import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'package:bridge/tether.dart';
import '../shared/tether_test.dart';
import 'package:bridge/http.dart';

class TetherTest implements TestCase {
  Tether tether;
  MockMessenger messenger;
  Container container;

  setUp() {
    container = new Container();
    messenger = new MockMessenger();
    tether = new Tether.make(container, new Session('token'), messenger);
  }

  tearDown() {}

  @test
  it_receives_data_with_resolving_function() async {
    bool wasCalled = false;
    tether.listen('key', (int data, MyClass myClass) {
      expect(data, equals(1));
      expect(myClass, new isInstanceOf<MyClass>());
      wasCalled = true;
    });
    messenger.messages.add(new Message('key', new Session('token'), 1));
    await null;
    await null;
    await null;
    expect(wasCalled, isTrue);
  }
}

class MyClass {
}

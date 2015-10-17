import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import '../shared/tether_test.dart';
import 'package:bridge/http.dart';
import 'package:bridge/src/tether/client/tether.dart';
import 'package:bridge/tether_shared.dart' hide Tether;

class TetherTest implements TestCase {
  Tether tether;
  MockMessenger messenger;

  setUp() {
    messenger = new MockMessenger();
    tether = new Tether(new Session('token'), messenger);
  }

  tearDown() {}

  @test
  it_receives_null_without_argument() async {
    bool wasCalled = false;
    tether.listen('key', () {
      wasCalled = true;
    });
    messenger.messages.add(new Message('key', new Session('token'), null));
    await null;
    await null;
    await null;
    expect(wasCalled, isTrue);
  }

  @test
  it_receives_value_with_argument() async {
    bool wasCalled = false;
    tether.listen('key', (value) {
      expect(value, equals(1));
      wasCalled = true;
    });
    messenger.messages.add(new Message('key', new Session('token'), 1));
    await null;
    await null;
    await null;
    expect(wasCalled, isTrue);
  }
}

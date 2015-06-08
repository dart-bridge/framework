import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/events.dart';

class EventsTest implements TestCase {
  setUp() {
  }

  tearDown() {}

  @test
  it_can_be_used_to_fire_domain_events() async {
    var wasCalled = false;
    Event.on('test').listen((event) {
      wasCalled = true;
      expect(event, equals('hello'));
    });
    Event.fire('test', 'hello');
    await null;
    expect(wasCalled, isTrue);
  }

  @test
  it_can_be_used_as_a_mixin() async {
    var instance = new MyEmittingClass();
    var wasCalled = false;
    instance.on('test').listen((event) {
      wasCalled = true;
      expect(event, equals('hello'));
    });
    instance.fire('test', 'hello');
    await null;
    expect(wasCalled, isTrue);
  }
}

class MyEmittingClass extends Object with Events {

}

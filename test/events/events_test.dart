import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/events.dart';

class EventsTest implements TestCase {
  Events events;

  setUp() {
    events = new Events();
  }

  tearDown() {}

  @test
  it_can_be_used_to_fire_domain_events() async {
    final event = new MyEvent();

    events.on(MyEvent).listen((MyEvent event) {
      event.wasCalled = true;
    });

    events.fire(event);

    // Skip a tick for event to be sent to the listeners
    await null;

    expect(event.wasCalled, isTrue);
  }

  @test
  event_ids_can_be_overriden() async {
    bool wasCalled = false;

    events.on(#custom).listen((String message) {
      expect(message, equals('x'));
      wasCalled = true;
    });

    events.fire('x', as: #custom);

    // Skip a tick for event to be sent to the listeners
    await null;

    expect(wasCalled, isTrue);
  }
}

class MyEvent {
  bool wasCalled = false;
}
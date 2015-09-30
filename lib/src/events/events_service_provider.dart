part of bridge.events;

class EventsServiceProvider implements ServiceProvider {
  Future setUp(Container container) async {
    container.singleton(new Events());
  }
}

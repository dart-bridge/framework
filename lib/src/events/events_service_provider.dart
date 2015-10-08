part of bridge.events;

class EventsServiceProvider extends ServiceProvider {
  Future setUp(Container container) async {
    container.singleton(new Events());
  }
}

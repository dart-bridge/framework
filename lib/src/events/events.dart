part of bridge.events;

class Events {
  final Map<dynamic, StreamController> _controllers = {};

  StreamController _controller(id) {
    return _controllers[id] ??= new StreamController.broadcast();
  }

  void fire(Object event, {as}) {
    return _controller(as ?? event.runtimeType).add(event);
  }

  Stream on(eventId) {
    return _controller(eventId).stream;
  }
}
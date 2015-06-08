part of bridge.events;

abstract class Event {
  static final Map<String, StreamController> _domainControllers = {};

  static Stream on(String key) {
    var controller = new StreamController();
    _domainControllers[key] = controller;
    return controller.stream;
  }

  static void fire(String key, data) {
    if (_domainControllers.containsKey(key))
      _domainControllers[key].add(data);
  }
}

abstract class Events {
  final Map<String, StreamController> _instanceControllers = {};

  Stream on(String key) {
    var controller = new StreamController();
    _instanceControllers[key] = controller;
    return controller.stream;
  }

  void fire(String key, data) {
    if (_instanceControllers.containsKey(key))
      _instanceControllers[key].add(data);
  }
}
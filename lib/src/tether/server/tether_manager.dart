part of bridge.tether;

typedef void TetherHandler(Tether tether);

abstract class TetherManager {
  factory TetherManager() => new _TetherManager();

  void registerHandler(TetherHandler handler);

  void manage(Tether tether);

  void broadcast(String key, [data]);
}

class _TetherManager implements TetherManager {
  final List<TetherHandler> _handlers = [];
  final List<Tether> _tethers = [];

  void registerHandler(TetherHandler handler) {
    _handlers.add(handler);
  }

  void manage(Tether tether) {
    _passTetherThroughHandlers(tether);
    _tethers.add(tether);
    if (tether.onConnectionLost != null)
      tether.onConnectionLost.then((_) => _tethers.remove(tether));
  }

  void _passTetherThroughHandlers(Tether tether) {
    _handlers.forEach((h) => h(tether));
  }

  void broadcast(String key, [data]) {
    _tethers.forEach((t) => t.send(key, data));
  }
}

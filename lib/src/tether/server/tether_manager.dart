part of bridge.tether;

typedef void TetherHandler(Tether tether);

abstract class TetherManager {
  factory TetherManager() => new _TetherManager();

  void registerHandler(TetherHandler handler);

  void manage(Tether tether);
}

class _TetherManager implements TetherManager {
  final List<TetherHandler> _handlers = [];

  void registerHandler(TetherHandler handler) {
    _handlers.add(handler);
  }

  void manage(Tether tether) {
    _passTetherThroughHandlers(tether);
  }

  void _passTetherThroughHandlers(Tether tether) {
    _handlers.forEach((h) => h(tether));
  }
}

part of bridge.tether;

class Tether extends TetherBase with _ServerTether {
  final Container _container;

  factory Tether(http.Session session, TetherManager manager) {
    return manager.fromSession(session);
  }

  Tether.make(Container this._container, http.Session session, Messenger messenger)
      : super(session, messenger);
}

abstract class _ServerTether {
  final Container _container;

  Future applyData(data, Function listener) {
    return _container.resolve(listener, injecting: {data.runtimeType: data});
  }
}

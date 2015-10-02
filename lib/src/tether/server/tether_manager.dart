part of bridge.tether;

typedef void TetherHandler(Tether tether);

abstract class TetherManager {
  factory TetherManager() => new _TetherManager();

  void registerHandler(TetherHandler handler);

  void manage(Tether tether);

  void broadcast(String key, [data]);

  Tether fromSession(http.Session session);
}

class _TetherManager implements TetherManager {
  final List<TetherHandler> _handlers = [];
  final List<Tether> _tethers = [];
  final List<PendingTether> _pendingTethers = [];

  void registerHandler(TetherHandler handler) {
    _handlers.add(handler);
  }

  void manage(Tether tether) {
    _pendingTethers
        .where((t) => t.session.id == tether.session.id)
        .forEach((t) => _connectPending(t, tether));
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

  Tether fromSession(http.Session session) {
    return _tethers.firstWhere((t) => t.session == session, orElse: () {
      final pending = new PendingTether(session);
      _pendingTethers.add(pending);
      return pending;
    });
  }

  Future _connectPending(PendingTether pending, Tether tether) async {
    _pendingTethers.remove(pending);
    tether.onConnectionEstablished
        .then(pending._connectionEstablishedCompleter.complete);
    tether.onConnectionLost
        .then(pending._connectionLostCompleter.complete);
    for (final pendingListener in pending._pendingListeners)
      tether.listen(pendingListener['key'], pendingListener['listener']);
    for (final pendingListener in pending._pendingSingleListeners)
      tether.listenOnce(pendingListener['key'], pendingListener['listener']);
    for (final pendingPayload in pending._pendingPayloads) {
      if (pendingPayload['exception'])
        tether.sendException(pendingPayload['key'], pendingPayload['data']);
      else
        tether.send(pendingPayload['key'], pendingPayload['data'])
            .then(pendingPayload['completer'].complete);
    }
    for (final modulator in pending._returnValueModulators)
      tether.modulateBeforeSerialization(modulator);
  }
}

class PendingTether extends _ServerTether implements Tether {
  final http.Session _session;
  final List<Map<String, dynamic>> _pendingPayloads = [];
  final List<Map<String, dynamic>> _pendingListeners = [];
  final List<Map<String, dynamic>> _pendingSingleListeners = [];
  final Set<Function> _returnValueModulators = new Set();
  final Completer _connectionEstablishedCompleter = new Completer();
  final Completer _connectionLostCompleter = new Completer();

  PendingTether(http.Session this._session);

  http.Session get session => _session;

  Container get _container => null;

  void initiatePersistentConnection() {
    throw new StateError('This Tether is not yet connected!');
  }

  void listen(String key, Function listener) {
    _pendingListeners.add({
      'key': key, 'data': listener
    });
  }

  void listenOnce(String key, Function listener) {
    _pendingSingleListeners.add({
      'key': key, 'data': listener
    });
  }

  void modulateBeforeSerialization(modulation(value)) {
    _returnValueModulators.add(modulation);
  }

  Future get onConnectionEstablished {
    return _connectionEstablishedCompleter.future;
  }

  Future get onConnectionLost {
    return _connectionLostCompleter.future;
  }

  Future send(String key, [data]) {
    final completer = new Completer();
    _pendingPayloads.add({
      'key': key,
      'data': data,
      'completer': completer,
      'exception': false
    });
    return completer.future;
  }

  void sendException(String key, Exception exception) {
    _pendingPayloads.add({
      'key': key,
      'data': exception,
      'exception': true
    });
  }
}

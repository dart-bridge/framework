part of bridge.tether;

class _CompatibleWebSocketAnchor implements Anchor {
  final http_parser.CompatibleWebSocket _socket;
  final StreamController<String> _controller = new StreamController();
  final Completer _onClose = new Completer();

  _CompatibleWebSocketAnchor(this._socket) {
    _listen();
  }

  Future _listen() async {
    await for (final payload in _socket)
        _controller.add(payload);
    _onClose.complete();
  }

  void close() {
    _socket.close();
  }

  bool get isOpen => _socket.closeCode == null;

  Future get onClose => _onClose.future;

  Future get onOpen async => null;

  Sink<String> get sink => _socket;

  Stream<String> get stream => _controller.stream;
}

@DependsOn(http.HttpServiceProvider)
class TetherServiceProvider extends ServiceProvider {
  Tethers tethers = new Tethers.empty();
  Application app;

  setUp(Application app) async {
    this.app = app;
    app.singleton(tethers, as: Tethers);
    app.singleton(new TetherManager(tethers));
    Messenger.serializer = serializer;
  }

  load(http.Server server, http.SessionManager sessions) {
    server.addMiddleware(shelf.createMiddleware(requestHandler: _handle), highPriority: true);
  }

  shelf.Response _handle(shelf.Request request) {
    void createTether(http_parser.CompatibleWebSocket socket) {
      tethers.add(new _CompatibleWebSocketAnchor(socket), session: request.context['session']);
    }

    shelf.Handler handler = ws.webSocketHandler(createTether);
    try {
      // Attempt to upgrade WebSocket, hijacking the [shelf.Request] and therefore
      // throwing [shelf.HijackException].
      handler(request);
      // Upgrade failed, send down to catch.
      throw new Exception();
    } on shelf.HijackException {
      // [shelf.HijackException] should move down to the shelf core.
      rethrow;
    } catch(e) {
      // Upgrade failed, so proceed through the [shelf.Pipeline].
      return null;
    }
  }
}
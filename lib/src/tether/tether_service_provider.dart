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
    Session.factory = (id, data) => new http.Session(id, data);
    Messenger.serializer = serializer;
  }

  load(http.Server server, http.SessionManager sessions) {
    // For backwards compatibility only. Include the [TetherMiddleware] in Pipeline.
    server.addMiddleware(new TetherMiddleware(tethers), highPriority: true);
  }
}

class TetherMiddleware extends http.Middleware {
  final Tethers _tethers;

  TetherMiddleware(this._tethers);

  Future<shelf.Response> handle(shelf.Request request) async {
    final session = new http.PipelineAttachment.of(request).session;

    void createTether(http_parser.CompatibleWebSocket socket) {
      _tethers.add(new _CompatibleWebSocketAnchor(socket), session: session);
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
    } catch (e) {
      // Upgrade failed, so proceed through the [shelf.Pipeline].
      return super.handle(inject(request, _tethers.get(session), as: Tether));
    }
  }
}

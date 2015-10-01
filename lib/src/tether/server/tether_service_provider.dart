part of bridge.tether;

Container _helperContainer;

class TetherServiceProvider implements ServiceProvider {
  TetherManager manager = new TetherManager();

  setUp(Application app, Container helperContainer) async {
    _helperContainer = helperContainer;
    app.singleton(manager, as: TetherManager);
  }

  load(http.Server server) {
    server.addMiddleware(shelf.createMiddleware(requestHandler: _handle), highPriority: true);
  }

  shelf.Response _handle(shelf.Request request) {
    shelf.Handler handler = ws.webSocketHandler(_attachSocket);
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

  Future _attachSocket(http_parser.CompatibleWebSocket socket) async {
    Tether tether = await ServerTetherMaker.makeTether(socket, Message.generateToken());
    manager.manage(tether);
  }
}
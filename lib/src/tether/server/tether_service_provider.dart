part of bridge.tether;

@DependsOn(http.HttpServiceProvider)
class TetherServiceProvider extends ServiceProvider {
  TetherManager manager = new TetherManager();
  Application app;

  setUp(Application app) async {
    this.app = app;
    app.singleton(manager, as: TetherManager);
  }

  load(http.Server server, http.SessionManager sessions) {
    server.addMiddleware(shelf.createMiddleware(requestHandler: _handle), highPriority: true);
    transportSessionReAttacher = _createReAttacher(sessions);
  }

  SessionReAttacher _createReAttacher(http.SessionManager sessions) {
    return (List serialized) {
      final String id = serialized[0];
      final Map<String, dynamic> variables = serialized[1];
      return sessions.session(id)..variables.addAll(variables);
    };
  }

  shelf.Response _handle(shelf.Request request) {
    Future _attachSocket(http_parser.CompatibleWebSocket socket) async {
      Tether tether = await ServerTetherMaker
          .makeTether(app, socket, request.context['session']);
      manager.manage(tether);
    }

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
}
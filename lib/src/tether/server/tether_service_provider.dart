part of bridge.tether;

class TetherServiceProvider implements ServiceProvider {
  TetherManager manager = new TetherManager();

  setUp(Application app) async {
    app.singleton(manager, as: TetherManager);
  }

  load(IoServer server) {
    server.setSocketHandler(_handleSocket);
  }

  Future _handleSocket(WebSocket socket) async {
    Tether tether = await ServerTetherMaker.makeTether(socket, Message.generateToken());
    manager.manage(tether);
  }
}
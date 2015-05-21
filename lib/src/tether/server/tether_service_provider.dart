part of bridge.tether.server;

class TetherServiceProvider implements ServiceProvider {

  Map<String, Tether> _tetherSessions = {};

  setUp(Controller controller, Application app) async {

    if (controller is! HandlesTether) {

      throw new TetherException('The controller must handle tethers! Implement HandlesTether!');
    }

    app.singleton(controller, as: HandlesTether);
  }

  load(IoServer server, HandlesTether handler) {

    server.setSocketHandler((WebSocket socket) async {

      Tether tether = await ServerSocketAdapter.makeTether(socket, Message.generateToken());

      _tetherSessions[tether.token] = tether;

//      print('connection with ${tether.token} established');

      handler.tether(tether);

      tether.listen('__||view', (String path) async {

        return await new File('views/${path.replaceAll('.','/')}.hbs').readAsString();
      });

      tether.onConnectionLost.then((_) {

//        print('connection with ${tether.token} ended');
        _tetherSessions.remove(tether.token);
      });
    });
  }
}
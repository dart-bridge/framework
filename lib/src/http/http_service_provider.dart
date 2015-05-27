part of bridge.http;

class HttpServiceProvider implements ServiceProvider {
  Server server;
  Router router;

  setUp(Container container, _Server server, Router router) {
    this.server = server;
    this.router = router;

    server._attachRouter(router);

    container.singleton(server, as: Server);
    container.singleton(router, as: Router);
  }

  load(Program program, Server server) {
    program.addCommand(start);
    program.addCommand(stop);
  }

  tearDown() async {
    await stop();
  }

  @Command('Start the server')
  start() async {
    await server.start();
  }

  @Command('Stop the server')
  stop() async {
    await server.stop();
  }
}

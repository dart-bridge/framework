part of bridge.http;

class HttpServiceProvider implements ServiceProvider {
  Server server;
  Router router;
  Program program;

  setUp(Container container, _Server server, Router router) {
    this.server = server;
    this.router = router;

    server.attachRouter(router);

    container.singleton(server, as: Server);
    container.singleton(router, as: Router);
  }

  load(Program program, Server server) {
    this.program = program;
    program.addCommand(start);
    program.addCommand(stop);
    program.addCommand(routes);
  }

  tearDown() async {
    await stop();
  }

  @Command('Start the server')
  start() async {
    await server.start();
    program.printInfo('Server started on http://${server.hostname}:${server.port}');
  }

  @Command('Stop the server')
  stop() async {
    await server.stop();
    program.printInfo('Server stopped');
  }

  @Command('List all the end-points defined in the router')
  routes() async {
    var table = new dlog.Table(3);

    for (var row in router._routes) {
      table.data.addAll([
        row.method,
        row.route,
        row.name == null ? '<nameless>' : row.name,
      ]);
    }

    print(table);
  }
}

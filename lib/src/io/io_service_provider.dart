part of bridge.io;

/// Binds the IoServer to the container, so that middleware can be attached
/// in other Service Providers' load method.
///
///     class MyServiceProvider {
///     
///       load(IoServer server) {
///         server.addMiddleware(...);
///       }
///     }
class IoServiceProvider implements ServiceProvider {

  IoServer server;

  @Command('Start the server')
  open() async {
    await server.run();
  }

  @Command('Stop the server')
  close() async {
    print('Stopping server');

    await server.close();
  }

  setUp(Container container, Config config) async {
    server = new _IoServer()
      .._port = config('app.server.port', 1337)
      .._hostname = config('app.server.hostname', 'localhost');

    container.singleton(server, as: IoServer);
  }

  run(IoServer server, Program program, Config config) async {
    server.setHandler(createStaticHandler(config.env('APP_WEB_ROOT', 'build/web'), serveFilesOutsidePath: true));

    program.addCommand(open);
    program.addCommand(close);
  }

  tearDown(IoServer server) async {
    await close();
  }
}
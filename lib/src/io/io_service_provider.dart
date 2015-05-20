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

  setUp(Container container, Config config) async {
    var server = new _IoServer()
      .._port = config('app.server.port', 1337)
      .._hostname = config('app.server.hostname', 'localhost');

    container.singleton(server, as: IoServer);
  }

  run(IoServer server) async {
    server.setHandler(createStaticHandler('web', serveFilesOutsidePath: true));

    await server.run();
  }

  tearDown(IoServer server) async {
    print('Stopping server');

    await server.close();
  }
}
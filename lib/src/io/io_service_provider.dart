part of bridge.io;

class IoServiceProvider implements ServiceProvider {

  Container container;

  IoServiceProvider(Container this.container);

  setUp(IoServer server) async {

    container.singleton(server);
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
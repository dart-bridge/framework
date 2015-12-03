part of bridge.http;

class HttpServiceProvider extends ServiceProvider {
  Server server;

  setUp(Application app) {
    server = new Server();
    app.singleton(server);
  }

  load(Program program) {
    program.addCommand(start);
    program.addCommand(stop);
  }

  run(Container container) {
    try {
      final Pipeline pipeline = container.make(Pipeline);
      server.usePipeline(pipeline);
    } on ContainerException {
      throw new ConfigException(
          'There must be a Pipeline implementation '
              'bound to the Container for the Server to work.');
    }
  }

  @Command('Start the server')
  start() => server.start();

  @Command('Stop the server')
  stop() => server.stop();
}

part of bridge.http;

class HttpServiceProvider extends ServiceProvider {
  Server server;

  setUp(Application app, Server server, Router router) {
    app.singleton(router, as: Router);
    app.singleton(server);
    this.server = server;
  }

  load(Program program, HttpConfig config, UrlGenerator urlGenerator) {
    _helperConfig = config;
    _helperUrlGenerator = urlGenerator;
    program.addCommand(start);
    program.addCommand(stop);
  }

  tearDown() async {
    if (server.isRunning)
      await stop();
  }

  run(Container container) {
    try {
      final Pipeline pipeline = container.make(Pipeline);
      server.usePipeline(pipeline);
    } on ContainerException {
      print('''
<red-background><white>  WARNING!  </white></red-background>
<red>No Pipeline is bound in the Container. Instead, the fallback Pipeline
will be used to allow backwards compatibility. This behaviour is
deprecated and will be replaced with an exception soon. To remove this
notice, bind an implementation of the Pipeline class in a Service Provider.</red>

<green>@DependsOn</green>(<cyan>HttpServiceProvider</cyan>)
<yellow>class</yellow> <cyan>PipelineServiceProvider </cyan><yellow>extends</yellow> <cyan>ServiceProvider </cyan>{
  load(<cyan>Container </cyan>container) {
    container.bind(<cyan>Pipeline</cyan>, <cyan>MyPipeline</cyan>);
  }
}

<yellow>class</yellow> <cyan>MyPipeline </cyan><yellow>extends</yellow> <cyan>Pipeline </cyan>{}
      '''.trim());
    }
  }

  @Command('Start the server')
  start() async {
    try {
      final url = await server.start();
      print('<blue>Server started on <underline>$url</underline>.</blue>');
    } on StateError catch(e) {
      print('<yellow>${e.message}</yellow>');
    }
  }

  @Command('Stop the server')
  stop() async {
    try {
      await server.stop();
      print('<blue>Server stopped.</blue>');
    } on StateError catch(e) {
      print('<yellow>${e.message}</yellow>');
    }
  }
}

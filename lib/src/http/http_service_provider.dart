part of bridge.http;

UrlGenerator _urlGenerator;

class HttpServiceProvider implements ServiceProvider {
  Server server;
  Router router;
  Program program;

  setUp(Container container,
        Server server,
        Router router,
        _ResponseMapper responseMapper,
        SessionManager manager) {
    this.server = server;
    this.router = router;

    server.attachRouter(router);

    container.singleton(responseMapper);
    container.singleton(server, as: Server);
    container.singleton(router, as: Router);
    container.singleton(manager);
  }

  load(Program program,
       SessionsMiddleware sessionsMiddleware,
       CsrfMiddleware csrfMiddleware,
       StaticFilesMiddleware staticFilesMiddleware,
       InputMiddleware inputMiddleware,
       UrlGenerator urlGenerator) {
    _urlGenerator = urlGenerator;

    server.addMiddleware(sessionsMiddleware, highPriority: true);
    server.addMiddleware(staticFilesMiddleware);
    server.addMiddleware(inputMiddleware);
    server.addMiddleware(csrfMiddleware);
    server.onError = (e, s) {
      print('');
      program.printInfo(new trace.Chain.forTrace(s).terse
      .toString().split('\n').take(5).toList().reversed.join('\n'));
      print('');
      program.printWarning('<underline>Error in HTTP layer:</underline>');
      program.printInfo(e);
      print('');
    };

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
    try {
      await server.stop();
      program.printInfo('Server stopped');
    } catch (e) {
    }
  }

  @Command('List all the end-points defined in the router')
  routes() async {
    var table = new dlog.Table(3);

    table.columns.addAll([
      'Method',
      'End-point',
      'Name',
    ]);

    for (var row in router._routes) {
      table.data.addAll([
        row.method,
        row.route,
        row.name == null ? '' : row.name,
      ]);
    }

    print(table);
  }
}

part of bridge.http;

class Server {
  final _BackwardsCompatibilityPipeline _fallbackPipeline;
  final Container _container;
  final HttpConfig _config;
  Pipeline _pipeline;
  _HttpServer _runningServer;

  Server(Container container, this._config)
      : _container = container,
        _fallbackPipeline = new _BackwardsCompatibilityPipeline(container);

  String get hostname => _config.host;

  int get port => _config.port;

  bool get isRunning => _runningServer != null;

  Pipeline get pipeline => _pipeline ?? _fallbackPipeline;

  void usePipeline(Pipeline pipeline) {
    _pipeline = pipeline;
  }

  Future<String> start() async {
    if (isRunning) throw new StateError('The server is already running!');
    _runningServer = new _HttpServer(handle, _config);
    if (_config.useSsl) {
      await _runningServer.startSecure();
      return 'https://$hostname:${_config.sslPort} (http://$hostname:$port)';
    }
    await _runningServer.start();
    return 'http://$hostname:$port';
  }

  Future stop() async {
    if (!isRunning)
      throw new StateError('The server isn\'t running!');
    await _runningServer.stop();
    _runningServer = null;
  }

  Future<shelf.Response> handle(shelf.Request request) {
    return pipeline.handle(request, _container);
  }

  @Deprecated('very soon. Create a middleware instead')
  void modulateRouteReturnValue(modulation(value)) {
    _fallbackPipeline.modulateRouteReturnValue(modulation);
  }

  @Deprecated("very soon. "
      "The app's Pipeline must include the Middleware instead.")
  void addMiddleware(Object middleware, {bool highPriority: false}) {
    _fallbackPipeline.addMiddleware(middleware, highPriority: highPriority);
  }

  @Deprecated('very soon. Create a middleware instead')
  void handleException(Type exceptionType, Function handler) {
    _fallbackPipeline.handleException(exceptionType, handler);
  }

  @Deprecated('very soon. Bind a router in container instead')
  void attachRouter(Router router) {}
}

class _BackwardsCompatibilityPipeline extends Pipeline {
  final Container _container;
  final List middlewareList = [];
  final Map errorHandlersMap = {};

  _BackwardsCompatibilityPipeline(this._container);

  @override get middleware => new List.from(defaultMiddleware)
    ..addAll(middlewareList);

  @override get errorHandlers => errorHandlersMap;

  void addMiddleware(Object middleware, {bool highPriority: false}) {
    if (highPriority) {
      middlewareList.insert(0, middleware);
    } else {
      middlewareList.add(middleware);
    }
  }

  void handleException(Type exceptionType, Function handler) {
    errorHandlersMap[exceptionType] = handler;
  }

  void modulateRouteReturnValue(modulation(value)) {
    addMiddleware(
        new _RouteReturnValueModulationMiddleware(_container, modulation));
  }
}

class _RouteReturnValueModulationMiddleware extends Middleware {
  final Container _container;
  final Function _modulation;

  _RouteReturnValueModulationMiddleware(this._container, this._modulation);

  Future<shelf.Response> handle(shelf.Request request) {
    return super.handle(convert(
        request,
        Object,
        _modulation
    ));
  }
}

class _HttpServer {
  final shelf.Handler handler;
  final HttpConfig config;
  HttpServer server;
  HttpServer secureServer;

  _HttpServer(this.handler, this.config);

  Future start() async {
    await _start(handler);
  }

  Future startSecure() async {
    secureServer = await HttpServer.bindSecure(
        config.host,
        config.sslPort,
        new SecurityContext()
          ..useCertificateChain(config.certificate)
          ..usePrivateKey(
              config.privateKey, password: config.privateKeyPassword)
    );
    if (config.port != config.sslPort)
      await _start(const shelf.Pipeline()
          .addHandler((shelf.Request request) {
        return new shelf.Response.seeOther(
            'https://${config.host}:${config.sslPort}/${request.url}');
      }));
    shelf_io.serveRequests(secureServer, handler);
  }

  Future _start(shelf.Handler handler) async {
    server = await HttpServer.bind(config.host, config.port);
    shelf_io.serveRequests(server, handler);
  }

  Future stop() async {
    await server?.close();
    await secureServer?.close();
  }
}

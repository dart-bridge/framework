part of bridge.http;

abstract class Server {
  factory Server(Config config, Container container)
  => new _Server(config, container);

  String get hostname;

  int get port;

  Future start();

  Future stop();

  void addMiddleware(shelf.Middleware middleware);

  void handleException(Type exceptionType, Function handler);

  void modulateRouteReturnValue(modulation(value));

  void attachRouter(Router router);

  void attachSessionManager(SessionManager sessionManager);

  Future<shelf.Response> handle(shelf.Request request);
}

class _Server implements Server {
  Router _router;
  HttpServer _server;
  String _host;
  int _port;
  Set<shelf.Middleware> _middleware = new Set();
  Set<Function> _returnValueModulators = new Set();
  Container _container;
  Config _config;
  SessionManager _sessions;

  String get hostname => _host;

  int get port => _port;

  _Server(Config this._config, Container this._container) {
    _host = _config('http.server.host', 'localhost');
    _port = _config('http.server.port', 1337);
  }

  void attachRouter(Router router) {
    _router = router;
  }

  void attachSessionManager(SessionManager sessions) {
    _sessions = sessions;
  }

  void addMiddleware(shelf.Middleware middleware) {
    _middleware.add(middleware);
  }

  Future<HttpServer> start() async {
    var pipeline = const shelf.Pipeline()
    .addMiddleware(shelf.createMiddleware(errorHandler: _globalErrorHandler))
    .addMiddleware(shelf.createMiddleware(requestHandler: _staticHandler))
    .addMiddleware(shelf.createMiddleware(responseHandler: _globalResponseHandler));
    _middleware.forEach((m) => pipeline = pipeline.addMiddleware(m));
    return _server = await shelf_io.serve(pipeline.addHandler(handle), _host, _port);
  }

  Future<shelf.Response> _staticHandler(shelf.Request request) async {
    shelf.Handler staticHandler = shelf_static.createStaticHandler(_publicRoot(), serveFilesOutsidePath: true);
    if (await new File('${_publicRoot()}/${request.url.path}').exists())
      return staticHandler(request);
    return null;
  }

  String _publicRoot() {
    return _config('http.server.publicRoot', 'web');
  }

  shelf.Response _globalErrorHandler(error, StackTrace stack) {
    new Future.microtask(() => throw error);
    if (error is HttpNotFoundException)
      return new shelf.Response.notFound('404 Not Found');
    return new shelf.Response.internalServerError(body: 'Internal Server Error');
  }

  shelf.Response _globalResponseHandler(shelf.Response response) {
    return response.change(headers: {'X-Powered-By': 'Bridge for Dart'});
  }

  Future<shelf.Response> handle(shelf.Request request) async {
    Input input = await _getInputFor(request);
    Session session = _sessions.sessionOf(request);
    for (Route route in _router._routes) {
      if (_routeMatch(route, request, input))
        return _routeResponse(route, request, input, session);
    }
    throw new HttpNotFoundException(request);
  }

  Future<Input> _getInputFor(shelf.Request request) async {
    if (!new RegExp(r'^(GET|HEAD)$').hasMatch(request.method))
      return await new InputParser(request).parse();
    return new Input({});
  }

  bool _routeMatch(Route route, shelf.Request request, Input input) {
    var method = input.containsKey('_method')
    ? input['_method']
    : request.method;
    return route.matches(method, request.url.path);
  }

  Future<shelf.Response> _routeResponse(Route route,
                                        shelf.Request request,
                                        Input input,
                                        Session session) async {
    var returnValue = await _container.resolve(route.handler,
    injecting: {
      shelf.Request: request,
      Input: input,
      Session: session,
    },
    namedParameters: route.wildcards(request.url.path));
    return _valueToResponse(returnValue);
  }

  Future<shelf.Response> _valueToResponse(Object value, [int statusCode = 200]) async {
    for (var m in _returnValueModulators) {
      value = await m(value);
    }
    if (value is shelf.Response) return value;
    return new shelf.Response(statusCode, body: _bodyFromValue(value), headers: {
      'Content-Type': _contentTypeFromValue(value).toString()
    });
  }

  String _bodyFromValue(Object value) {
    if (_isJsonEncodable(value)) return JSON.encode(value);
    return value.toString();
  }

  ContentType _contentTypeFromValue(Object value) {
    if (_isJsonEncodable(value)) return ContentType.JSON;
    return ContentType.HTML;
  }

  bool _isJsonEncodable(Object value) {
    return value is Iterable || value is Map;
  }

  Future stop() async {
    if (_server == null) return;
    await _server.close();
  }

  void handleException(Type exceptionType, Function handler, {int statusCode: 500}) {
    this.addMiddleware(shelf.createMiddleware(errorHandler: (Object exception, StackTrace stack) async {
      if (exception.runtimeType == exceptionType)
        return _valueToResponse(await _container.resolve(handler, injecting: {Exception: exception}), statusCode);
      throw exception;
    }));
  }

  void modulateRouteReturnValue(modulation(value)) {
    _returnValueModulators.add(modulation);
  }
}

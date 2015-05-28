part of bridge.http;

abstract class Server {
  Future start();

  Future stop();

  void addMiddleware(shelf.Middleware middleware);

  void handleException(Type exceptionType, Function handler);

  void modulateRouteReturnValue(modulation(value));

  void _attachRouter(Router router);
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

  _Server(Config this._config, Container this._container) {
    _host = _config('http.server.host', 'localhost');
    _port = _config('http.server.port', 1337);
  }

  void _attachRouter(Router router) {
    _router = router;
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
    return _server = await shelf_io.serve(pipeline.addHandler(_routeHandler), _host, _port);
  }

  Future<shelf.Response> _staticHandler(shelf.Request request) async {
    shelf.Handler staticHandler = shelf_static.createStaticHandler(_publicRoot(), serveFilesOutsidePath: true);
    if (await new File('${_publicRoot()}/${request.url.path}').exists())
      return staticHandler(request);
    return null;
  }

  String _publicRoot() {
    return _config('app.server.publicRoot', 'web');
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

  Future<shelf.Response> _routeHandler(shelf.Request request) async {
    Input input = await _getInputFor(request);
    for (Route route in _router._routes) {
      if (_routeMatch(route, request)) return _routeResponse(route, request, input);
    }
    throw new HttpNotFoundException(request);
  }

  Future<Input> _getInputFor(shelf.Request request) async {
    if (!new RegExp(r'^(GET|HEAD)$').hasMatch(request.method))
      return await new InputParser(request).parse();
    return new Input({});
  }

  bool _routeMatch(Route route, shelf.Request request) {
    return route.matches(request.method, request.url.path);
  }

  Future<shelf.Response> _routeResponse(Route route, shelf.Request request, Input input) async {
    var returnValue = await _container.resolve(route.handler,
    injecting: {shelf.Request: request, Input: input},
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

  void handleException(Type exceptionType, Function handler) {
    this.addMiddleware(shelf.createMiddleware(errorHandler: (Object exception, StackTrace stack) async {
      if (exception.runtimeType == exceptionType)
        return _valueToResponse(await _container.resolve(handler, injecting: {Exception: exception}), 404);
      throw exception;
    }));
  }

  void modulateRouteReturnValue(modulation(value)) {
    _returnValueModulators.add(modulation);
  }
}

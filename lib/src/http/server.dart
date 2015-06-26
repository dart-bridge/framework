part of bridge.http;

abstract class Server {
  Function onError;

  factory Server(Config config, Container container)
  => new _Server(config, container);

  String get hostname;

  int get port;

  Future start();

  Future stop();

  void addMiddleware(shelf.Middleware middleware, {bool highPriority});

  void handleException(Type exceptionType, Function handler);

  void modulateRouteReturnValue(modulation(value));

  void attachRouter(Router router);

  Future<shelf.Response> handle(shelf.Request request);
}

class _Server implements Server {
  Router _router;
  HttpServer _server;
  String _host;
  int _port;
  List<shelf.Middleware> _middleware = new List();
  Set<Function> _returnValueModulators = new Set();
  Container _container;
  Config _config;
  Function onError = (e, s) {
    print(e);
    print(s);
  };

  String get hostname => _host;

  int get port => _port;

  _Server(Config this._config, Container this._container) {
    _host = _config('http.server.host', 'localhost');
    _port = _config('http.server.port', 1337);
  }

  void attachRouter(Router router) {
    _router = router;
  }

  void addMiddleware(shelf.Middleware middleware, {bool highPriority: false}) {
    if (highPriority) return _middleware.insert(0, middleware);
    _middleware.add(middleware);
  }

  Future<HttpServer> start() async {
    return _server = await shelf_io.serve(_buildPipeline(), _host, _port);
  }

  shelf.Response _globalErrorHandler(error, StackTrace stack) {
    onError(error, stack);
    if (error is HttpNotFoundException)
      return new shelf.Response.notFound('404 Not Found');
    return new shelf.Response.internalServerError(body: 'Internal Server Error');
  }

  shelf.Response _globalResponseHandler(shelf.Response response) {
    return response.change(headers: {'X-Powered-By': 'Bridge for Dart'});
  }

  shelf.Handler _buildPipeline() {
    var pipeline = const shelf.Pipeline()
    .addMiddleware(shelf.createMiddleware(errorHandler: _globalErrorHandler))
    .addMiddleware(shelf.createMiddleware(responseHandler: _globalResponseHandler));
    _middleware.forEach((m) => pipeline = pipeline.addMiddleware(m));
    return pipeline.addHandler(_handle);
  }

  Future<shelf.Response> handle(shelf.Request request) async {
    return _buildPipeline()(request);
  }

  Future<shelf.Response> _handle(shelf.Request request) async {
    for (Route route in _router._routes) {
      if (_routeMatch(route, request))
        return _routeResponse(route, request);
    }
    throw new HttpNotFoundException(request);
  }

  bool _routeMatch(Route route, shelf.Request request) {
    Input input = request.context['input'];
    var method = input.containsKey('_method')
    ? input['_method']
    : request.method;
    return route.matches(method, request.url.path);
  }

  Future<shelf.Response> _routeResponse(Route route,
                                        shelf.Request request) async {
    var returnValue = await _container.resolve(route.handler,
    injecting: {
      shelf.Request: request,
      Input: _clearPrivates(request.context['input']),
      Session: request.context['session'],
    },
    namedParameters: route.wildcards(request.url.path));
    return _valueToResponse(returnValue);
  }

  Object _clearPrivates(Map map) {
    map.keys.where((k) => k.startsWith('_')).toList().forEach((k) {
      map.remove(k);
    });
    return map;
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
    if (_server == null) throw new Exception('The server isn\'t running');
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

part of bridge.http;

abstract class Server {
  Function onError;

  factory Server(Config config, Container container)
  => new _Server(config, container);

  String get hostname;

  int get port;

  Future start();

  Future stop();

  void addMiddleware(Object middleware, {bool highPriority});

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
  Container _container;
  Config _config;
  _ResponseMapper _responseMapper;
  Function onError = (e, s) {
    print(e);
    print(s);
  };

  String get hostname => _host;

  int get port => _port;

  _Server(Config this._config, Container this._container) {
    _responseMapper = _container.make(_ResponseMapper);
    _host = _config('http.server.host', 'localhost');
    _port = _config('http.server.port', 1337);
  }

  void attachRouter(Router router) {
    _router = router;
  }

  var _highPriorityMiddleware = 0;

  void addMiddleware(Object middleware, {bool highPriority: false}) {
    shelf.Middleware shelfMiddleware = _createMiddleware(middleware);
    if (highPriority) return _middleware.insert(
        _highPriorityMiddleware++, shelfMiddleware);
    _middleware.add(shelfMiddleware);
  }

  shelf.Middleware _createMiddleware(Object middleware) {
    shelf.Middleware shelfMiddleware;
    if (middleware is Type)
      return _createMiddleware(_container.make(middleware));
    if (middleware is shelf.Middleware) shelfMiddleware = middleware;
    if (middleware is Middleware)
      shelfMiddleware = middleware.transform(_container);
    if (shelfMiddleware == null) throw new InvalidArgumentException(
        'Must be a [shelf.Middleware] or a [bridge.http.Middleware]');
    return shelfMiddleware;
  }

  Future<HttpServer> start() async {
    return _server = await shelf_io.serve(_buildPipeline(), _host, _port);
  }

  shelf.Response _globalErrorHandler(error, StackTrace stack) {
    onError(error, stack);
    if (error is HttpNotFoundException)
      return new shelf.Response.notFound('404 Not Found');
    return new shelf.Response.internalServerError(
        body: 'Internal Server Error');
  }

  shelf.Response _globalResponseHandler(shelf.Response response) {
    return response.change(headers: {'X-Powered-By': 'Bridge for Dart'});
  }

  shelf.Handler _buildPipeline() {
    var pipeline = const shelf.Pipeline()
        .addMiddleware(
        shelf.createMiddleware(errorHandler: _globalErrorHandler))
        .addMiddleware(
        shelf.createMiddleware(responseHandler: _globalResponseHandler));
    _middleware.forEach((m) =>
    pipeline = pipeline.addMiddleware(_conditionalMiddleware(m)));
    return pipeline.addHandler(_handle);
  }

  shelf.Middleware _conditionalMiddleware(shelf.Middleware middleware) {
    return (shelf.Handler innerHandler) {
      return (shelf.Request request) {
        if (_shouldUseMiddlewareForRequest(request, middleware))
          return middleware(innerHandler)(request);
        return innerHandler(request);
      };
    };
  }

  bool _shouldUseMiddlewareForRequest(shelf.Request request,
      shelf.Middleware middleware) {
    for (Route route in _router._routes) {
      if (_routeMatch(route, request))
        return !route.ignoredMiddleware.contains(middleware.runtimeType);
    }
    return true;
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
    String method = (input != null && input.containsKey('_method'))
        ? input['_method']
        : request.method;
    return route.matches(method, request.url.path);
  }

  Future<shelf.Response> _routeResponse(Route route,
      shelf.Request request) {
    return _routeMiddleware(route, request, (request) async {
      var injecting = {
        shelf.Request: request,
      };
      if (request.context.containsKey('input'))
        injecting[Input] = _clearPrivates(request.context['input']);
      if (request.context.containsKey('session'))
        injecting[Session] = request.context['session'];
      var returnValue = await
      _container.resolve(route.handler,
          injecting: injecting..addAll(route._shouldInject),
          namedParameters: route.wildcards(request.url.path));
      return _responseMapper.valueToResponse(returnValue);
    });
  }

  Future<shelf.Response> _routeMiddleware(Route route, shelf.Request request,
      shelf.Handler handler) {
    var pipeline = const shelf.Pipeline();
    for (final middleware in route.appendedMiddleware) {
      pipeline = pipeline.addMiddleware(_createMiddleware(middleware));
    }
    return pipeline.addHandler(handler)(request);
  }

  Object _clearPrivates(Map map) {
    map.keys.where((k) => k.startsWith('_')).toList().forEach((k) {
      map.remove(k);
    });
    return map;
  }

  Future stop() async {
    if (_server == null) throw new Exception('The server isn\'t running');
    await _server.close();
  }

  void handleException(Type exceptionType, Function handler,
      {int statusCode: 500}) {
    this.addMiddleware(shelf.createMiddleware(
        errorHandler: (Object exception, StackTrace stack) async {
          if (reflectType(exception.runtimeType).isAssignableTo(
              reflectType(exceptionType)))
            return _responseMapper.valueToResponse(
                await _container.resolve(handler, injecting: {
                  exceptionType: exception,
                  Exception: exception,
                  StackTrace: stack,
                }), statusCode);
          print(exception);
          print(stack);
          throw exception;
        }));
  }

  void modulateRouteReturnValue(modulation(value)) {
    _responseMapper.modulateRouteReturnValue(modulation);
  }
}

class _ResponseMapper {
  Set<Function> _returnValueModulators = new Set();
  Serializer _serializer;

  _ResponseMapper(Serializer this._serializer);

  Future<shelf.Response> valueToResponse(Object value,
      [int statusCode = 200]) async {
    for (var m in _returnValueModulators)
      value = await m(value);
    if (value is shelf.Response) return value;
    if (value is Stream)
      return _streamResponse(value, statusCode);
    return new shelf.Response(
        statusCode, body: _bodyFromValue(value), headers: {
      'Content-Type': _contentTypeFromValue(value).toString()
    });
  }

  shelf.Response _streamResponse(Stream stream, int statusCode) {
    var contentType = ContentType.HTML;
    final newStream = () async* {
      await for (final item in stream) {
        if (item is String) yield item;
        else {
          contentType = ContentType.JSON;
          yield JSON.encode(serializer.serialize(item));
        }
      }
    }().map(UTF8.encode);
    return new shelf.Response(
        statusCode, body: newStream, headers: {
      'Content-Type': contentType.toString()
    });
  }

  void modulateRouteReturnValue(modulation(value)) {
    _returnValueModulators.add(modulation);
  }

  Object _bodyFromValue(Object value) {
    if (_isJsonEncodable(value)) return JSON.encode(
        _serializer.serialize(value));
    return value.toString();
  }

  ContentType _contentTypeFromValue(Object value) {
    if (_isJsonEncodable(value)) return ContentType.JSON;
    return ContentType.HTML;
  }

  bool _isJsonEncodable(Object value) {
    return value is Iterable || value is Map;
  }
}
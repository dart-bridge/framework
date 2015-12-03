part of bridge.http;

typedef ErrorHandler(error, StackTrace stackTrace);

abstract class Pipeline {
  final Router _router;
  final Container _container;

  Pipeline(this._router, this._container) {
    routes(_router);
  }

  List get middleware => [];

  Map<Type, ErrorHandler> get errorHandlers => {};

  routes(Router router);

  Future<shelf.Response> handle(shelf.Request request) async {
    final route = _router._routes.firstWhere(_routeMatches(request),
        orElse: () => throw new HttpNotFoundException(request));
    final middleware = _setUpMiddleware(route);
    var pipeline = const shelf.Pipeline();
    for (final m in middleware)
      pipeline = pipeline.addMiddleware(m);
    final handler = pipeline.addHandler(_routeHandler(route));
    try {
      return await handler(request);
    } catch (exception, stack) {
      final mirror = reflect(exception);
      final type = errorHandlers.keys.firstWhere((type) {
        return mirror.type.isAssignableTo(reflectType(type));
      }, orElse: () => null);
      if (type == null) rethrow;
      final returnValue = await errorHandlers[type](exception, stack);
      return _makeResponse(returnValue);
    }
  }

  shelf.Handler _routeHandler(Route route) {
    return (shelf.Request request) async {
      final attachment = _getAttachment(request);
      final injections = {shelf.Request: request}..addAll(
          route._shouldInject)..addAll(attachment.inject);
      final named = route.wildcards(request.url.path);
      final returnValue = await _container.resolve(
          route.handler,
          injecting: injections,
          namedParameters: named
      );
      final response = await _makeResponse(returnValue, attachment);
      return response;
    };
  }

  Future<shelf.Response> _makeResponse(rawValue,
      [RequestAttachment attachment]) async {
    final value = attachment == null
        ? rawValue
        : await _applyConversions(rawValue, attachment.convert);
    if (value is shelf.Response) return value;
    if (value is String || value is bool || value is num)
      return _htmlResponse(value);
    return _jsonResponse(value);
  }

  shelf.Response _htmlResponse(value) {
    return new shelf.Response.ok('$value', headers: {
      'Content-Type': ContentType.HTML.toString()
    });
  }

  Future<shelf.Response> _jsonResponse(value) async {
    final toSerialize = value is Stream ? await value.toList() : value;
    final serialized = serializer.serialize(toSerialize, flatten: true);
    return new shelf.Response.ok(JSON.encode(serialized), headers: {
      'Content-Type': ContentType.JSON.toString()
    });
  }

  Future _applyConversions(rawValue, Map<Type, Function> conversions) async {
    final mirror = reflect(rawValue);
    final type = conversions.keys.firstWhere((t) {
      return mirror.type.isAssignableTo(reflectType(t));
    }, orElse: () => null);
    if (type == null) return rawValue;
    final remainingConversions = new Map.from(conversions)
      ..remove(type);
    return _applyConversions(
        await conversions[type](rawValue), remainingConversions);
  }

  RequestAttachment _getAttachment(shelf.Request request) {
    return request.context[Middleware._attachmentKey]
        ?? new RequestAttachment.empty();
  }

  List<shelf.Middleware> _setUpMiddleware(Route route) {
    final all = new List.from(middleware);
    all.removeWhere(route.ignoredMiddleware.contains);
    for (final extra in route.appendedMiddleware)
      if (!all.contains(extra)) all.add(extra);
    return all.map(_conformMiddleware).toList(growable: false);
  }

  Function _routeMatches(shelf.Request request) {
    return (r) => r.matches(request.method, request.url.path);
  }

  shelf.Middleware _conformMiddleware(middleware) {
    if (middleware is shelf.Middleware)
      return middleware;
    if (middleware is Type)
      return _container.make(middleware);
    throw new ArgumentError.value(middleware,
        'middleware', 'must be a Type of class or function that'
            ' conforms to shelf.Middleware');
  }
}

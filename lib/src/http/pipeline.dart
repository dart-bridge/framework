part of bridge.http;

abstract class Pipeline {
  Container _container;

  List get middleware => [defaultMiddleware];

  List get defaultMiddleware => [
    StaticFilesMiddleware,
    InputMiddleware,
    SessionsMiddleware,
    CsrfMiddleware,
  ];

  Map<Type, Function> get errorHandlers => {};

  Future<shelf.Response> handle(shelf.Request request,
      Container container) async {
    _container = container;
    final Router router = _container.make(Router);
    final route = router._routes.firstWhere(_routeMatches(request),
        orElse: () => new Route(request.method,
            request.url.path, () => throw new HttpNotFoundException(request)));
    final middleware = _setUpMiddleware(route);
    var pipeline = const shelf.Pipeline();
    for (final m in middleware)
      pipeline = pipeline.addMiddleware(m);
    final handler = pipeline.addHandler(_routeHandler(route));
    return await handler(request);
  }

  Future<shelf.Response> _tryErrorHandlers(shelf.Request request, exception, stack) async {
    final mirror = reflect(exception);
    final type = errorHandlers.keys.firstWhere((type) {
      return mirror.type.isAssignableTo(reflectType(type));
    }, orElse: () => null);
    if (type == null) return null;
    final returnValue = await _container.resolve(
        errorHandlers[type], injecting: {
      exception.runtimeType: exception,
      Error: exception,
      Exception: exception,
      Object: exception,
      StackTrace: stack
    });
    return _makeResponse(returnValue, new PipelineAttachment.of(request));
  }

  shelf.Handler _routeHandler(Route route) {
    return (shelf.Request request) async {
      final attachment = new PipelineAttachment.of(request);
      final injections = {shelf.Request: request}..addAll(
          route._shouldInject)..addAll(attachment.inject);
      final named = route.wildcards(request.url.path);
      final returnValue = await _container.resolve(
          route.handler,
          injecting: injections,
          namedParameters: named
      );
      return _makeResponse(returnValue, attachment);
    };
  }

  Future<shelf.Response> _makeResponse(rawValue,
      [PipelineAttachment attachment]) async {
    reattachAttachment(shelf.Response response) {
      return response.change(context: {
        PipelineAttachment._contextKey: attachment
            ?? new PipelineAttachment.empty()
      });
    }
    final value = attachment == null
        ? rawValue
        : await _applyConversions(rawValue, attachment.convert);
    if (value is shelf.Response) return reattachAttachment(value);
    if (value is String || value is bool || value is num)
      return reattachAttachment(_htmlResponse(value));
    return reattachAttachment(await _jsonResponse(value));
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

  List<shelf.Middleware> _setUpMiddleware(Route route) {
    final all = _flatten([
      new _GlobalErrorHandlerMiddleware(_tryErrorHandlers),
      _HeaderTagMiddleware,
      middleware,
    ]).toList();

    all.removeWhere(route.ignoredMiddleware.contains);

    for (final extra in route.appendedMiddleware)
      if (!all.contains(extra)) all.add(extra);

    all.add(new _GlobalErrorHandlerMiddleware(_tryErrorHandlers));

    return all.map(_conformMiddleware).toList(growable: false);
  }

  Iterable _flatten(Iterable iterable) sync* {
    for (final item in iterable) {
      if (item is Iterable) {
        yield* _flatten(item);
      } else {
        yield item;
      }
    }
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

class _HeaderTagMiddleware extends Middleware {
  Future<shelf.Response> handle(shelf.Request request) {
    return super.handle(request).then(_applyHeaderTag);
  }

  shelf.Response _applyHeaderTag(shelf.Response response) {
    return response.change(headers: {
      'X-Powered-By': 'Bridge Framework ${Environment.bridge.version}'
    });
  }
}

class _GlobalErrorHandlerMiddleware extends Middleware {
  Function _handlers;

  _GlobalErrorHandlerMiddleware(this._handlers);

  Future<shelf.Response> handle(shelf.Request request) async {
    try {
      return await super.handle(request);
    } on shelf.HijackException {
      rethrow;
    } catch(_e, _s) {
      var error = _e;
      StackTrace stackTrace = _s;
      try {
        final attempt = await _handlers(request, error, stackTrace);
        if (attempt is shelf.Response) return attempt;
      } catch (_e, _s) {
        error = _e;
        stackTrace = _s;
      }
      final stack = new Chain.forTrace(stackTrace).terse
          .toString()
          .replaceAll(new RegExp(r'.*Program\.execute[^]*'),
          '===== program started ============================\n')
          .replaceAllMapped(new RegExp('^((dart:|===).*)', multiLine: true),
          (m) => '<gray>${m[0]}<yellow>')
          .replaceAllMapped(new RegExp('^(package:.*)', multiLine: true),
          (m) => '<red>${m[0]}<yellow>')
          .split('\n')
          .reversed
          .join('\n');
      final message = '   ' + error.toString().replaceAll('\n', '\n   ');
      print('''<yellow>$stack</yellow>
<red-background><white>

$message
</white></red-background>

<yellow><bold>Note:</bold> To mute this message, add an error handler for <underline>${error.runtimeType}</underline>:</yellow>

<yellow>class</yellow> <cyan>Main</cyan> <yellow>extends</yellow> <cyan>Pipeline</cyan> {
  <green>@override</green> <yellow>get</yellow> errorHandlers => {
    <cyan>${error.runtimeType}</cyan>: _handle${error.runtimeType}
  };

  _handle${error.runtimeType}(<cyan>${error.runtimeType}</cyan> error) {
    <yellow>return</yellow> <red>'Ouch! We encountered a(n) ${error.runtimeType}! Sorry about that!'</red>;
  }
}
''');

      if (error is HttpNotFoundException)
        return new shelf.Response.notFound('$error');
      return new shelf.Response.internalServerError(body: '$error');
    }
  }
}

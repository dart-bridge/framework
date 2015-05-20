part of bridge.io;

/// **Native HTTP Server implementation**
/// This is a thin wrapper around the [shelf](//pub.dartlang.org/packages/shelf)
/// pipeline, which, as a singleton, can be added middleware in
/// service providers. Also, delegates WebSockets to a handler.
abstract class IoServer {

  /// Add shelf middleware to the handler. This must be done
  /// in the `load` method of a service provider.
  addMiddleware(Middleware middleware);

  /// Set the actual handler of the request. This is done internally
  /// and should probably not be overridden.
  setHandler(Handler handler);

  /// Set the handler that handles a newly established WebSocket
  /// connection. This is done internally and should probably
  /// not be overridden.
  setSocketHandler(handler(WebSocket socket));

  /// Start the server
  Future run();

  /// Stop the server
  Future close();
}

class _IoServer implements IoServer {

  Pipeline _pipeline = const Pipeline();
  Handler _handler;
  String _hostname;
  int _port;
  HttpServer _server;
  Function _socketHandler;

  IoServer() {
    _addGlobalErrorHandlerMiddleware();
  }

  addMiddleware(Middleware middleware) {
    _pipeline = _pipeline.addMiddleware(middleware);
  }

  setHandler(Handler handler) {
    _handler = _pipeline.addHandler(handler);
  }

  setSocketHandler(handler(WebSocket socket)) {
    _socketHandler = handler;
  }

  _addGlobalErrorHandlerMiddleware() {
    addMiddleware(_createGlobalErrorHandlerMiddleware());
  }

  _createGlobalErrorHandlerMiddleware() {
    return createMiddleware(errorHandler: _globalErrorHandler);
  }

  Response _globalErrorHandler(error, StackTrace stack) {
    print(error);
    print(stack);
    return new Response.internalServerError();
  }

  Future run() async {
    await _startServer();
    print('Server started on http://${_server.address.host}:${_server.port}\n');
  }

  Future _startServer() async {
    _server = await _bindHttpServer();

    var c = new StreamController<HttpRequest>();
    _listenForHttpRequests(c);
    serveRequests(c.stream, _handler);
  }

  Future<HttpServer> _bindHttpServer() {
    return HttpServer.bind(_hostname, _port);
  }

  Future _listenForHttpRequests(StreamController<HttpRequest> requestController) async {
    await for (HttpRequest request in _server)
      await _handleRequest(request, requestController);
  }

  Future _handleRequest(HttpRequest request, StreamController<HttpRequest> requestController) async {
    if (_shouldUpgradeRequestToWebSocket(request))
      return _handleSocketUpgrade(request);
    requestController.add(request);
  }

  bool _shouldUpgradeRequestToWebSocket(HttpRequest request) => WebSocketTransformer.isUpgradeRequest(request);

  Future _handleSocketUpgrade(HttpRequest request) async {
    if (_socketHandler != null)
      _socketHandler(await WebSocketTransformer.upgrade(request));
  }

  Future close() async {
    await _server.close();
  }
}
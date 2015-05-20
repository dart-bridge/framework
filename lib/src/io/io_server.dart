part of bridge.io;

class IoServer {

  Pipeline _pipeline = const Pipeline();

  Handler _handler;

  String _hostname = 'localhost';

  int _port = 1337;

  HttpServer _server;

  IoServer() {

    addMiddleware(createMiddleware(
        errorHandler: (error, StackTrace stack) {

          print(error);
          print(stack);

          return new Response.internalServerError();
        }
    ));
  }

  addMiddleware(Middleware middleware) {

    _pipeline = _pipeline.addMiddleware(middleware);
  }

  setHandler(Handler handler) {

    _handler = _pipeline.addHandler(handler);
  }

  Function _socketHandler;

  setSocketHandler(handler(WebSocket socket)) {

    _socketHandler = handler;
  }

  Future run() async {

    _server = await HttpServer.bind(_hostname, _port);

    var _requestController = new StreamController<HttpRequest>();

    _server.listen((HttpRequest request) async {

      if (WebSocketTransformer.isUpgradeRequest(request)) {

        if (_socketHandler != null)
          _socketHandler(await WebSocketTransformer.upgrade(request));
        return;
      }
      _requestController.add(request);
    });

    serveRequests(_requestController.stream, _handler);

    print('Server started on http://${_server.address.host}:${_server.port}\n');
  }

  Future close() async {

    await _server.close();
  }
}
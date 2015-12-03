part of bridge.http;

class Server {
  void usePipeline(Pipeline pipeline) {
  }

  void start() {
  }

  void stop() {
  }

  @Deprecated("very soon. The app's Pipeline must include the Middleware instead.")
  void addMiddleware(shelf.Middleware createMiddleware, {bool highPriority}) {
  }

  @Deprecated('very soon. Create a middleware instead')
  void modulateRouteReturnValue(Function modulation) {
  }
}

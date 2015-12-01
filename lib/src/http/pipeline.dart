part of bridge.http.shared;

typedef ErrorHandler(error, StackTrace stackTrace);

abstract class Pipeline {
  List get middleware => [];

  Map<Type, ErrorHandler> get errorHandlers => {};

  routes(Router router);

  Future<shelf.Response> make(shelf.Request request) {}
}

part of bridge.http.shared;

abstract class Middleware {
  shelf.Handler _inner;

  shelf.Handler call(shelf.Handler inner) {
    this._inner = inner;
    return handle;
  }

  Future<shelf.Response> handle(shelf.Request request) async {
    return await _inner(request);
  }
}

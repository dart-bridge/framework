part of bridge.http;

class StaticFilesMiddleware {
  Config _config;

  StaticFilesMiddleware(Config this._config);

  call(shelf.Handler innerHandler) => shelf.createMiddleware(requestHandler: _staticHandler)(innerHandler);

  Future<shelf.Response> _staticHandler(shelf.Request request) async {
    shelf.Handler staticHandler = shelf_static.createStaticHandler(_publicRoot(), serveFilesOutsidePath: true);
    if (await new File('${_publicRoot()}/${request.url.path}').exists())
      return staticHandler(request);
    return null;
  }

  String _publicRoot() {
    return _config('http.server.publicRoot', 'web');
  }
}

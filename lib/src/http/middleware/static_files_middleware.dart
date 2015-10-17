part of bridge.http;

class StaticFilesMiddleware {
  Config _config;

  StaticFilesMiddleware(Config this._config);

  call(shelf.Handler innerHandler) => shelf.createMiddleware(requestHandler: _staticHandler)(innerHandler);

  Future<shelf.Response> _staticHandler(shelf.Request request) async {
    shelf.Handler staticHandler = shelf_static.createStaticHandler(_publicRoot(), serveFilesOutsidePath: true);
    if (await new File(path.join(_publicRoot(),request.url.path)).exists())
      return staticHandler(request);
    return null;
  }

  String _publicRoot() {
    final public = _config('http.server.public_root', 'web');
    final build = _config('http.server.build_root', 'build');
    return Environment.isProduction
        ? path.join(build, public)
        : public;
  }
}

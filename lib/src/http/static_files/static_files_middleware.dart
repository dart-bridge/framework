part of bridge.http;

class StaticFilesMiddleware extends Middleware {
  final HttpConfig _config;

  StaticFilesMiddleware(this._config);

  Future<shelf.Response> handle(shelf.Request request) async {
    shelf.Handler staticHandler = shelf_static.createStaticHandler(_publicRoot(), serveFilesOutsidePath: true);
    if (await new File(path.join(_publicRoot(),request.url.path)).exists())
      return staticHandler(request);
    return super.handle(request);
  }

  String _publicRoot() {
    return Environment.isProduction
        ? path.join(_config.buildRoot, _config.publicRoot)
        : _config.publicRoot;
  }
}

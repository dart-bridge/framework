part of bridge.view;

class ViewServiceProvider implements ServiceProvider {
  Router router;
  DocumentBuilder builder;
  Application app;

  setUp(Application application) {
    app = application;
    router = new Router();
    app.singleton(router, as: Router);
    app.bind(TemplateRepository, FileTemplateRepository);
  }

  load(IoServer server, TemplateRepository repository) {
    builder = new DocumentBuilder(repository);
    server.addMiddleware(_middleware());
  }

  Middleware _middleware() {
    return createMiddleware(requestHandler: _requestHandler);
  }

  Future _requestHandler(Request request) async {
    if (!await _staticFileExists(request.url.path))
      return _handleViewRequest(request);
  }

  Future<bool> _staticFileExists(String path) {
    return new File('web/$path').exists();
  }

  Future<Response> _handleViewRequest(Request request) async {
    try {
      return _serve(router.match(request.method, request.url.path));
    } on RoutesDoNotMatchException {
      return _serve404(router.notFoundHandler);
    }
  }

  Future<Response> _serve(Route route) async {
    return _handle(route.handler, 200);
  }

  Future<Response> _serve404(Function handler) async {
    return _handle(handler, 404);
  }

  Future<Response> _handle(Function handler, int statusCode) async {
    var returnValue = await app.resolve(handler);
    if (returnValue is Response) return returnValue;
    if (returnValue is ViewResponse) return _handleViewResponse(returnValue);
    return new Response(statusCode, body: returnValue);
  }

  Future<Response> _handleViewResponse(ViewResponse response) async {
    String template = await builder.fromTemplateName(response.templateName);
    return new Response.ok(template);
  }
}
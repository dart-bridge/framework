part of bridge.view;

class ViewServiceProvider implements ServiceProvider {
//  Router router;
//  DocumentBuilder builder;
//  Application app;
//  Config config;

//  setUp(Application application, Config config) {
  setUp(Application application) {
//    app = application;
//    this.config = config;
//    router = new Router();
//    app.singleton(router, as: Router);
    application.bind(TemplateRepository, FileTemplateRepository);
  }

  load(Server server, DocumentBuilder builder) {
    server.modulateRouteReturnValue((value) {
      if (value is ViewResponse)
        return _viewResponse(value, builder);
      if (value is Template)
        return _templateResponse(value, builder);
      return value;
    });
  }

  Future<String> _viewResponse(ViewResponse response, DocumentBuilder builder) {
    return builder.fromTemplateName(response.templateName, response.scripts);
  }

  Future<String> _templateResponse(Template template, DocumentBuilder builder) {
    return builder.fromTemplate(template);
  }
//
//  load(Server server, DocumentBuilder builder) {
//    this.builder = builder;
//    server.addMiddleware(_middleware());
//  }
//
//  Middleware _middleware() {
//    return createMiddleware(requestHandler: _requestHandler);
//  }
//
//  Future _requestHandler(Request request) async {
//    if (!await _staticFileExists(request.url.path))
//      return _handleViewRequest(request);
//  }
//
//  Future<bool> _staticFileExists(String path) {
//    return new File('${config.env('APP_WEB_ROOT', 'build/web')}/$path').exists();
//  }
//
//  Future<Response> _handleViewRequest(Request request) async {
//    try {
//      return _serve(router.match(request.method, request.url.path), request);
//    } on InvalidArgumentException {
//      return _serve404(router.notFoundHandler, request);
//    }
//  }
//
//  Future<Response> _serve(Route route, Request r) async {
//    return _handle(route.handler, 200, r);
//  }
//
//  Future<Response> _serve404(Function handler, Request r) async {
//    if (handler == null) return new Response.notFound('Not found');
//    return _handle(handler, 404, r);
//  }
//
//  Future<Response> _handle(Function handler, int statusCode, Request r) async {
//    var returnValue = await app.resolve(handler, injecting: {
//      Request: r
//    });
//    if (returnValue is Response) return returnValue;
//    if (returnValue is ViewResponse) return _handleViewResponse(returnValue, statusCode);
//
//    var contentType = (returnValue is String && returnValue.contains('<html')) ? ContentType.HTML : ContentType.TEXT;
//
//    if (returnValue is! String) {
//      returnValue = JSON.encode(returnValue);
//      contentType = ContentType.JSON;
//    }
//
//    return new Response(statusCode, body: returnValue, headers: {
//      'Content-Type': contentType.toString()
//    });
//  }
//
//  Future<Response> _handleViewResponse(ViewResponse response, int statusCode) async {
//    String template = await builder.fromTemplateName(response.templateName, response.scripts);
//    return new Response(statusCode, body: template, headers: {
//      'Content-Type': ContentType.HTML.toString()
//    });
//  }
}
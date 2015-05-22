part of bridge.view;

class ViewServiceProvider implements ServiceProvider {

  Config config;

  ViewServiceProvider(Config this.config);

  setUp(Controller controller, Application app) async {

    if (controller is! HandlesRoutes) {

      throw new ViewException('The controller must handle routes! Implement HandlesRoutes!');
    }

    app.singleton(controller, as: HandlesRoutes);
  }

  load(IoServer server, HandlesRoutes handler) async {

    server.addMiddleware(createMiddleware(
        requestHandler: (Request request) async {

          var file = new File('web/${request.url.path}');

          if (!await file.exists()) {

            return _handleViewRequest(request, handler);
          }
        }
    ));
  }

  Future<Response> _handleViewRequest(Request request, HandlesRoutes handler) async {

    String rootFolderPath = config['view.root'];

    if (rootFolderPath == null) rootFolderPath = 'views';

    var headTemplateFile = new File('$rootFolderPath/head.hbs');

    List<String> headSegments = [];

    if (await headTemplateFile.exists()) {

      var headTemplate = new Template(await headTemplateFile.readAsString());

      headSegments.add(headTemplate.headMarkup);
    }

    Router router = new Router(request.url.path);

    handler.routes(router);

    Template pageTemplate;

    var body = '';

    if (router.pointer != null) {

      var page = router.pointer.replaceAll('.', '/');

      var pageTemplateFile = new File('$rootFolderPath/$page.hbs');

      if (await pageTemplateFile.exists()) {

        pageTemplate = new Template(await pageTemplateFile.readAsString());

        headSegments.add(pageTemplate.headMarkup);

        body = pageTemplate.bodyMarkup;
      }
    }

    var script = (request.headers['user-agent'].contains('(Dart)'))
                 ? "<script type='application/dart' src='/main.dart'></script>"
                 : "<script src='/main.js'></script>";

    var template = '''
    <!DOCTYPE html>
    <html>
    <head>
    ${headSegments.join('')}
    <script src='/vue.js'></script>
    </head>
    <body unresolved>
    $body
    $script
    </body>
    </html>
    ''';

    var headers = {
      'Content-Type': 'text/html; charset=utf8'
    };

    if (!router.is404)
      return new Response.ok(template, headers: headers);
    return new Response.notFound(template, headers: headers);
  }
}
part of bridge.view;

class TemplatesMiddleware extends Middleware {
  Future<Response> handle(Request request) {
    return super.handle(convert(request, Template, (Template template) {
      return template.content.join('\n');
    }));
  }
}

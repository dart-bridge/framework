part of bridge.view;

class TemplatesMiddleware extends Middleware {
  Future<Response> handle(Request request) {
    return super.handle(convert(request, Template, (Template template) {
      final code = template.data['errorCode']
          ?? template.data['statusCode']
          ?? template.data['code']
          ?? template.data['status']
          ?? 200;
      return new Response(
          code is int ? code : 200,
          body: template.encoded, headers: {
        'Content-Type': ContentType.HTML.toString()
      });
    }));
  }
}

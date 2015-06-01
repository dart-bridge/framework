part of bridge.view;

class ViewServiceProvider implements ServiceProvider {
  DocumentBuilder builder;

  setUp(Application application) {
    application.bind(TemplateRepository, FileTemplateRepository);
  }

  load(Server server, DocumentBuilder builder) {
    this.builder = builder;
    server.modulateRouteReturnValue(_returnValueModulation);
  }

  _returnValueModulation(value) {
    if (value is ViewResponse)
      return _viewResponse(value, builder);
    if (value is Template)
      return _templateResponse(value, builder);
    return value;
  }

  Future<String> _viewResponse(ViewResponse response, DocumentBuilder builder) {
    return builder.fromTemplateName(
        response.templateName,
        response.scripts,
        response.data);
  }

  Future<String> _templateResponse(Template template, DocumentBuilder builder) {
    return builder.fromTemplate(template);
  }
}
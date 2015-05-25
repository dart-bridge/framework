part of bridge.view;

class TemplateNotFoundException extends ViewException {

  TemplateNotFoundException(String id) : super('The template [$id] was not found');
}
part of bridge.view;

abstract class TemplateRepository {
  Future<Template> find(String templateName);
}
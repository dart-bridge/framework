part of bridge.view;

class TemplateResponse {
  final String templateName;
  final List<String> scripts;
  final Map<String, dynamic> data;

  const TemplateResponse(String this.templateName,
                     List<String> this.scripts,
                     Map<String, dynamic> this.data);
}
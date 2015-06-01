part of bridge.view;

class ViewResponse {
  final String templateName;
  final List<String> scripts;
  final Map<String, dynamic> data;

  const ViewResponse(String this.templateName,
                     List<String> this.scripts,
                     Map<String, dynamic> this.data);
}
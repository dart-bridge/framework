part of bridge.view;

ViewResponse view(String templateName, {String withScript, List<String> withScripts}) {
  var scripts = <String>[];
  if (withScript != null) scripts.add(withScript);
  if (withScripts != null) scripts.addAll(withScripts);
  return new ViewResponse(templateName, scripts);
}
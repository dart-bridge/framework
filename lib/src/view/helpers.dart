part of bridge.view;

Future<Template> template(String templateName,
                {String withScript,
                List<String> withScripts,
                Map<String, dynamic> withData: const {}}) {

  List<String> scripts = withScripts != null ? withScripts.toList() : [];

  if (withScript != null) scripts.add(withScript);

  return _templates.template(templateName, withData, scripts);
}
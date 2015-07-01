part of bridge.view;

Future<String> template(String templateName,
                {String withScript,
                List<String> withScripts: const [],
                Map<String, dynamic> withData: const {}}) {
  if (withScript != null) withScripts.add(withScript);
  return _templates.template(templateName, withData, withScripts);
}
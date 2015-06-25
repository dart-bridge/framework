part of bridge.view;

Future<String> template(String templateName,
                {String withScript,
                List<String> withScripts,
                Map<String, dynamic> withData: const {}}) {
  return _templates.template(templateName, withData);
}
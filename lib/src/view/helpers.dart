part of bridge.view;

TemplateResponse template(String templateName,
                      {String withScript,
                      List<String> withScripts,
                      Map<String, dynamic> withData}) {

  var data = <String, dynamic>{};
  if (withData != null) data.addAll(withData);

  var scripts = <String>[];
  if (withScript != null) scripts.add(withScript);
  if (withScripts != null) scripts.addAll(withScripts);

  return new TemplateResponse(templateName, scripts, data);
}
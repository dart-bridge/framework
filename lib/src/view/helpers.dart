part of bridge.view;

TemplateResponse template(String templateName,
                          {String withScript,
                          List<String> withScripts,
                          Map<String, dynamic> withData,
                          String as}) {

  var data = <String, dynamic>{};
  if (withData != null) data.addAll(withData);

  var scripts = <String>[];
  if (withScript != null) scripts.add(withScript);
  if (withScripts != null) scripts.addAll(withScripts);

  Type parser = as == null
  ? null
  : _templateParsers.containsKey(as)
  ? _templateParsers[as]
  : throw new TemplateException('Parser [$as] does not exist');

  return new TemplateResponse(templateName, scripts, data, parser);
}
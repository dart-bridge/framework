part of bridge.view;

TemplateBuilder template(String templateName,
    {String withScript,
    List<String> withScripts,
    Map<String, dynamic> withData: const {}}) {
  List<String> scripts = withScripts != null ? withScripts.toList() : [];

  if (withScript != null) scripts.add(withScript);

  return new TemplateBuilder(templateName)
      .withScripts(scripts)
      .withData(withData);
}


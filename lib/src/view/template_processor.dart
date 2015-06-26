part of bridge.view;

class TemplateProcessor {
  final Map<String, String> _scripts = {};

  Future include(String name,
               String script,
               {List<TemplatePreProcessor> preProcessors: const []}) async {
    for(var preProcessor in preProcessors)
      script = await preProcessor.process(script);
    _scripts[name] = (script == null) ? '' : script;
  }

  String get templateScript => '''
import 'package:bridge/view.dart';
import 'dart:async';

class Templates extends TemplateCollection {
  Map<String, TemplateCollectionItem> get templates => {
${_scripts.keys
  .map((name) => '    "$name": () async => """${_scripts[name]}""",')
  .join('\n')}
  };
}''';
}
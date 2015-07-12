part of bridge.view;

class JadePreProcessor implements TemplatePreProcessor {
  final String _expressionMatcher =
  r'((?:\((?:\((?:\((?:\((?:\((?:\((?:\((?:\(\)'
  r'|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?)';
  final Config _config;

  JadePreProcessor(Config this._config);

  Future<String> process(String template) async {
    template = template == null ? '' : template;

    template = _preProcess(template);

    var tempFile = new File('.temp_jade${new DateTime.now().millisecondsSinceEpoch}');
    await tempFile.writeAsString(template);
    try {

      var jadedPreCompilation = jade.renderFiles(_config('view.templates.root', 'lib/templates'), [tempFile]);
      await tempFile.delete();

      jadedPreCompilation = jadedPreCompilation.split('\'${path.basename(tempFile.path)}\': ')[1];

      jadedPreCompilation = jadedPreCompilation.replaceFirst('([Map locals]){', 'await (locals) async {');

      jadedPreCompilation = r'${' + _jadedImports() + jadedPreCompilation.replaceFirst(new RegExp(r'},\/\/\/jade-end\n};'), '}(data)}');

      return jadedPreCompilation;

    }
    catch (e) {
      await tempFile.delete();
      rethrow;
    }
  }

  String _jadedImports() {
    return '''
__--import 'package:jaded/runtime.dart';
__--import 'package:jaded/runtime.dart' as jade;
    ''';
  }

  String _preProcess(String template) {
    return _directives(template);
  }

  String _directives(String template) {
    var directives = {
      'extends': null,
      'include': null,
      'block': 'end block',
    };
    for (var directive in directives.keys) {
      if (directives[directive] != null)
        template = template.replaceAllMapped(
            new RegExp(r'(^[ \t]*)''$directive'r'\s*(.*)\n((?:[ \t]*(?:\n|$)|\1\s+.*(?:\n|$))+)', multiLine: true),
                (m) {
              var contents = m[3].replaceAll(new RegExp('^${m[1]}\\s+', multiLine: true), m[1]);
              if (contents.trim() == '') return m[0];
              return '${m[1]}| @start $directive (${m[2]})\n$contents${m[1]}| @${directives[directive]}\n';
            });
      template = template.replaceAllMapped(new RegExp('(^\\s*)$directive(.*)', multiLine: true),
          (m) => '${m[1]}| @$directive (${m[2]})');
    }

    return template;
  }
}

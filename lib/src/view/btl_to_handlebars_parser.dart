part of bridge.view;

class BtlToHandlebarsParser implements TemplateParser {
  static final String _variableMatchString = r'\$(?:\{([\w.]+)}|(\w+))';
  static final RegExp _variableMatcher = new RegExp(_variableMatchString);
  UrlGenerator _urlGenerator;

  BtlToHandlebarsParser(UrlGenerator this._urlGenerator);

  String parse(String template, [Map<String, dynamic> data]) {
    template = _removeComments(template);
    template = _translateForLoops(template);
    template = _translateIfStatements(template);
    template = _translateVariables(template);
    template = _extendFormMethods(template);
    template = _formRouteActions(template);
    return template;
  }

  RegExp _r(String expression) => new RegExp(expression);

  String _translateVariables(String template) {
    template = _escapeDollarsigns(template);
    template = template.replaceAllMapped(_variableMatcher, (m) {
      var name = _variableValue(m[1], m[2]);
      return '{{ $name }}';
    });
    template = _reinsertDollarsigns(template);
    return template;
  }

  String _variableValue(String matchWithoutBraces, String matchWithBraces) {
    return matchWithBraces == null ? matchWithoutBraces : matchWithBraces;
  }

  String _escapeDollarsigns(String template) {
    return template.replaceAll(r'\$', '___ESCAPEDDOLLARSIGN____');
  }

  String _reinsertDollarsigns(String template) {
    return template.replaceAll('___ESCAPEDDOLLARSIGN____', r'$');
  }

  String _translateForLoops(String template) {
    return template.replaceAllMapped(
        new RegExp(r'<for (?:each=\$(\w+) )?in='
        + _variableMatchString + r'>([^]*?)</for>'),
        _translateForLoop);
  }

  String _translateForLoop(Match match) {
    var loopedVar = _variableValue(match[2], match[3]);
    var contents = match[4];
    if (match[1] != null)
      contents = contents.replaceAllMapped(_r(r'\$(\{)?''${match[1]}\.'), (m) => '\$${m[1]}');
    return '{{# $loopedVar }}$contents{{/ $loopedVar }}';
  }

  String _translateIfStatements(String template) {
    RegExp matcher = _r(r'<if ' + _variableMatchString + '>((?:(?!<if)[^])*?)<\/if>');
    while (matcher.hasMatch(template)) {
      template = template.replaceFirstMapped(matcher, (m) {
        var name = _variableValue(m[1], m[2]);
        return '{{# $name }}${m[3]}{{/ $name }}';
      });
    }
    return template;
  }

  String _removeComments(String btl) {
    btl = btl.replaceAllMapped(new RegExp(r'''(['"])(.*)\/\/(.*)\1'''), (Match match) {
      return '${match[1]}${match[2]}/_ESCAPEDCOMMENT_/${match[3]}${match[1]}';
    });
    return btl
    .replaceAll(new RegExp(r'\/\/.*$', multiLine: true), '')
    .replaceAll('/_ESCAPEDCOMMENT_/', '//');
  }

  String _extendFormMethods(String btl) {
    var matcher = new RegExp(
        r'''<form([^>]*?)method=(['"])(.*?)\2([^>]*?)>''',
        caseSensitive: false);
    return btl.replaceAllMapped(matcher, (Match match) {
      var method = match[3];
      var hiddenInput = '';
      if (!new RegExp('(GET|POST)').hasMatch(method)) {
        hiddenInput = "<input type='hidden' name='_method' value='${method.toUpperCase()}'>";
        method = 'POST';
      }
      var reconstruction = "<form${match[1]}method='$method'${match[4]}>$hiddenInput";
      return reconstruction;
    });
  }
  
  String _formRouteActions(String btl) {
    return btl.replaceAllMapped(new RegExp(r'''<form([^]*?)route=(['"])(.*?)\2'''), (m) {
      return "<form${m[1]}action='${_urlGenerator.route(m[3])}'";
    });
  }
}

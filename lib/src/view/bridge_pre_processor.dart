part of bridge.view;

class BridgePreProcessor implements TemplatePreProcessor {
  Future<String> process(String template) async {
    return
      _removeComments(
          _extendFormMethods(
              _transpileInstantiations(
                  _directives(template == null ? '' : template))));
  }

  RegExp _r(String expression,
            {bool multiLine,
            bool caseSensitive}) => new RegExp(
      expression,
      multiLine: multiLine,
      caseSensitive: caseSensitive);

  String _expressionMatcher =
  r'((?:\((?:\((?:\((?:\((?:\((?:\((?:\((?:\(\)'
  r'|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?\)|[^])*?)';

  String _bracedExpressionMatcher =
  r'(^|(?!\\).)\$\{((?:\{(?:\{(?:\{(?:\{(?:\{(?:\{(?:\{(?:\'
  r'{\}|[^])*?\}|[^])*?\}|[^])*?\}|[^])*?\}|[^])*?\}|[^])*?\}|[^])*?\}|[^])*?)\}';

  String _directives(String template) {
    return template

    // @extends @block @end block
    .replaceAllMapped(_r(
        r'@extends\s*\(''$_expressionMatcher'r'\)([^]*@end\s*block)'), (m) {
      var expression = m[1];
      var contents = m[2];
      var outerBlockMatcher = _r(r'^(\s*)@block\s*\(''$_expressionMatcher'r'\)([^]*?)^\1@end\s*block', multiLine: true);
      var inlineOuterBlockMatcher = _r(r'()@start block\s*\(''$_expressionMatcher'r'\)(.*?)@end\s*block', multiLine: true);
      List<Match> matches = []
        ..addAll(inlineOuterBlockMatcher.allMatches(contents))
        ..addAll(outerBlockMatcher.allMatches(contents));
      Iterable<String> blocks = matches.map((m) {
        var expression = m[2];
        var contents = m[3];
        return '$expression: """$contents"""';
      });

      return r'${await $extends(''$expression, {${blocks.join(',')}})}';
    })

    // @block
    .replaceAllMapped(_r(
        r'@(?:start )?block\s*\(''$_expressionMatcher'r'\)'), (m) {
      var expression = m[1];
      return r'${$block(''$expression'')}';
    })

    // @if
    .replaceAllMapped(_r(
        r'@if\s*\(''$_expressionMatcher'r'\)'), (m) {
      var expression = m[1];
      return r'${await (() async => (''$expression'') ? """';
    })

    // @else if
    .replaceAllMapped(_r(
        r'@else\s+if\s*\(''$_expressionMatcher'r'\)'), (m) {
      var expression = m[1];
      return r'""" : (''$expression'') ? """';
    })

    // @else
    .replaceAll(
        _r(r'@else\s*'), '""" : true ? """'
    )

    // @end if
    .replaceAll(
        _r(r'@end\s+if\s*'), '""" : "")()}'
    )

    // @if
    .replaceAllMapped(_r(
        r'@for\s*\(\s*([A-Za-z_]\w*)\s+in\s+''$_expressionMatcher'r'\)'), (m) {
      var varName = m[1];
      var expression = m[2];
      return r'${(await Future.wait((''$expression'').map((''$varName'') async => """';
    })

    // @end for
    .replaceAll(
        _r(r'@end\s+for\s*'), '"""))).join("")}'
    )

    // @include
    .replaceAllMapped(_r(
        r'@include\s*\(''$_expressionMatcher'r'\)'), (m) {
      var expression = m[1];
      return r'${await $include(''$expression'')}';
    })

    ;
  }

  String _removeComments(String template) {
    template = template.replaceAllMapped(_r(r'''(['"])(.*)\/\/(.*)\1'''), (Match match) {
      return '${match[1]}${match[2]}/_ESCAPEDCOMMENT_/${match[3]}${match[1]}';
    });
    return template
    .replaceAll(_r(r'\/\/.*$', multiLine: true), '')
    .replaceAll('/_ESCAPEDCOMMENT_/', '//');
  }

  String _extendFormMethods(String template) {
    var matcher = _r(
        r'''<form([^>]*?)method=(['"])(.*?)\2([^>]*?)>''',
        caseSensitive: false);
    return template.replaceAllMapped(matcher, (Match match) {
      var method = match[3];
      var hiddenInput = '';
      if (!_r('(GET|POST)').hasMatch(method)) {
        hiddenInput = "<input type='hidden' name='_method' value='${method.toUpperCase()}'>";
        method = 'POST';
      }
      var reconstruction = "<form${match[1]}method='$method'${match[4]}>$hiddenInput";
      return reconstruction;
    });
  }

  String _transpileInstantiations(String template) {
    return template.replaceAllMapped(_r(_bracedExpressionMatcher), (m) {
      return '${m[1]}\${${_transpileInstantiationsInExpression(m[2])}}';
    });
  }

  String _transpileInstantiationsInExpression(String expression) {
    return expression.replaceAllMapped(_r(r'''new\s*([A-Za-z_][\w.]*)\s*\(\s*([^]*)\s*\)(?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)'''), (m) {
      var afterSymbol = m[2] == '' ? '' : ', ${m[2]}';
      return '\$instantiate(#${m[1]}$afterSymbol)';
    });
  }
}

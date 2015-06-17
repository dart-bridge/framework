part of bridge.view;

class BtlParser implements TemplateParser {
  Future<String> parse(String btl, [Map<String, dynamic> data]) async {
    btl = _removeComments(btl);
    btl = _transformRepeats(btl);
    print(btl);
    btl = await new ExpressionParser().parse(btl, _ensureMap(data));
    btl = _transformIfStatements(btl);
    btl = _extendFormMethods(btl);

    return btl;
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

  String _removeComments(String btl) {
    btl = btl.replaceAllMapped(new RegExp(r'''(['"])(.*)\/\/(.*)\1'''), (Match match) {
      return '${match[1]}${match[2]}/_ESCAPEDCOMMENT_/${match[3]}${match[1]}';
    });
    return btl
    .replaceAll(new RegExp(r'\/\/.*$', multiLine: true), '')
    .replaceAll('/_ESCAPEDCOMMENT_/', '//');
  }

  String _transformIfStatements(String btl) {
    RegExp truthyMatcher = new RegExp(r'<if true>((?:(?!<if)[^])*?)<\/if>');
    RegExp falsyMatcher = new RegExp(r'<if false>(?:(?!<if)[^])*?<\/if>');
    while (falsyMatcher.hasMatch(btl))
      btl = btl.replaceFirst(falsyMatcher, '');
    while (truthyMatcher.hasMatch(btl))
      btl = btl.replaceFirstMapped(truthyMatcher, (m) => m[1]);
    while (falsyMatcher.hasMatch(btl))
      btl = btl.replaceFirst(falsyMatcher, '');
    return btl;
  }

  Map<String, dynamic> _ensureMap(Map<String, dynamic> map) {
    return (map == null) ? <String, dynamic>{} : map;
  }

  String _transformRepeats(String btl) {
    return btl.replaceAllMapped(
        new RegExp(r'<for (?:each=\$([A-Za-z_]\w*) )?in=\$([A-Za-z_]\w*|{[^}]*})>([^]*?)</for>'),
            (m) {
              var each = m[1] == null ? '_' : m[1];
              var list = m[2];
              var contents = m[3].replaceAllMapped(new RegExp(r'\$(?:''$each''|{([^]*?)''$each''([^]*?)})'), (m) {
                var before = m[1] == null ? '' : m[1];
                var after = m[2] == null ? '' : m[2];
               return '\${$before$list[__index]$after}';
              });
              return '"""+new List.generate((await request("$list.length")), (i) => i).map((__index)async=>"""$contents""").join("")+"""';
        });
  }
}

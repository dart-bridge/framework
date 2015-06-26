part of bridge.view;

class BridgePreProcessor implements TemplatePreProcessor {
  Future<String> process(String template) async {
    return _removeComments(_extendFormMethods(template == null ? '' : template));
  }

  String _removeComments(String btl) {
    btl = btl.replaceAllMapped(new RegExp(r'''(['"])(.*)\/\/(.*)\1'''), (Match match) {
      return '${match[1]}${match[2]}/_ESCAPEDCOMMENT_/${match[3]}${match[1]}';
    });
    return btl
    .replaceAll(new RegExp(r'\/\/.*$', multiLine: true), '')
    .replaceAll('/_ESCAPEDCOMMENT_/', '//');
  }

  String _extendFormMethods(String template) {
    var matcher = new RegExp(
        r'''<form([^>]*?)method=(['"])(.*?)\2([^>]*?)>''',
        caseSensitive: false);
    return template.replaceAllMapped(matcher, (Match match) {
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
}

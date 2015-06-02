part of bridge.view.template;

class BtlParser {
  Map<String, dynamic> _data;
  static final String _variableMatchString = r'\$(?:\{([\w.]+)}|(\w+))';
  static final RegExp _variableMatcher = new RegExp(_variableMatchString);

  String parse(String btl, [Map<String, dynamic> data]) {
    _data = _ensureMap(data);
    btl = _removeComments(btl);
    btl = _preEncodeEscaped(btl);
    btl = _flattenRepeats(btl);
    btl = _injectVariables(btl);
    btl = _parseIfStatements(btl);
    btl = _postDecodeEscaped(btl);

    return btl;
  }

  String _removeComments(String btl) {
    return btl.replaceAll(new RegExp(r'\/\/.*$', multiLine: true), '');
  }

  String _preEncodeEscaped(String btl) {
    return btl.replaceAll(r'\$', r'\$\');
  }

  String _postDecodeEscaped(String btl) {
    return btl.replaceAll(r'\$\', r'$');
  }

  String _parseIfStatements(String btl) {
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

  String _injectVariables(String btl) {
    return btl.replaceAllMapped(_variableMatcher, _injectVariable);
  }

  _injectVariable(Match match) {
    return _dataFromKey(_getKeyFromVariableMatch(match));
  }

  String _getKeyFromVariableMatch(Match match) {
    return (match[1] == null) ? match[2] : match[1];
  }

  _dataFromKey(String key) {
    var pointer = _data;
    for (dynamic segment in key.split('.'))
      pointer = _navigatePointerToNextKey(segment, pointer, key);
    return pointer;
  }

  _navigatePointerToNextKey(segment, pointer, String key) {
    if (_isIntParsible(segment))
      segment = int.parse(segment);
    if (_canNotNavigate(pointer, segment))
      throw new TemplateException('Data for with segment [$key] was not supplied.');
    return pointer[segment];
  }

  bool _canNotNavigate(pointer, key) {
    if (pointer is List)
      return (pointer.length < key + 1);
    else
      return !pointer.containsKey(key);
  }

  bool _isIntParsible(String string) {
    return new RegExp(r'^\d+$').hasMatch(string);
  }

  String _flattenRepeats(String btl) {
    return btl.replaceAllMapped(
        new RegExp(r'<for (?:each=\$(\w+) )?in='
        + _variableMatchString + r'>([^]*?)</for>'),
        _flattenRepeat);
  }

  String _flattenRepeat(Match match) {
    var out = '';
    var key = (match[2] == null) ? match[3] : match[2];
    for (var i = 0; i < _dataFromKey(key).length; ++i)
      out += _prependVariables(key, match[4], i, match[1]);
    return out;
  }

  String _prependVariables(String prefix, String contents, int index, String alias) {
    return contents.replaceAllMapped(_variableMatcher,
        (Match match) => '\${$prefix.$index.${_getKeyFromVariableMatchWithAlias(match, alias)}}');
  }

  _getKeyFromVariableMatchWithAlias(Match match, String alias) {
    alias = (alias == '') ? '' : '$alias.';
    return _getKeyFromVariableMatch(match).replaceFirst(new RegExp('^$alias'), '');
  }
}

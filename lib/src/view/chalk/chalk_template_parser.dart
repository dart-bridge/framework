part of bridge.view;

typedef String MatchMapper(Match $);

class ChalkTemplateParser implements TemplateParser {
  var _hasBeenUsedOnce = false;
  var _isExtending = false;
  var _expectsBlock = false;
  var _lineNumber = 0;

  Stream<String> parse(Stream<String> lines) async* {
    if (_hasBeenUsedOnce)
      throw new UnsupportedError(
          'The Chalk Template Parser can only parse one template per instance');
    _hasBeenUsedOnce = true;
    final parsedLines = lines.map(_parseLine).map((String line) {
      return line.replaceAll(new RegExp(r"yield '''\s*''';"), '');
    });
    yield* parsedLines;
    if (_isExtending)
      yield _endExtends();
  }

  String get extension => '.chalk.html';

  String _parseLine(String line) {
    _lineNumber++;
    if (_expectsBlock
        && line != ''
        && !line.startsWith(new RegExp(r'\s*@start\s*block')))
      throw new ParserException(_lineNumber,
          'Expected [@start block] but got [$line]');
    var parsedLine = _beforeTransforms(line);
    for (final pattern in _transformations.keys)
      parsedLine = parsedLine
          .replaceAllMapped(new RegExp(pattern), _transformations[pattern]);
    return "yield '''${_afterTransforms(parsedLine)}''';";
  }

  String _beforeTransforms(String line) {
    return line
        .replaceAll(r'\@', r'\@:')
        .replaceAll(r'\$', r'\$:');
  }

  String _afterTransforms(String line) {
    return line
        .replaceAll(r'\@:', r'@')
        .replaceAll(r'\$:', r'\$');
  }

  Map<String, MatchMapper> get _transformations => {
    _ChalkPatterns.variable: _variableFormat,
    _ChalkPatterns.directive('if', arg: true): _directiveMapper(_ifFormat),
    _ChalkPatterns.directive('else if', arg: true):
    _directiveMapper(_elseIfFormat),
    _ChalkPatterns.directive('else'): _directiveMapper(_elseFormat),
    _ChalkPatterns.directive('end if'): _directiveMapper(_endIfFormat),
    _ChalkPatterns.forLoop: _directiveMapper(_forFormat),
    _ChalkPatterns.directive('end for'): _directiveMapper(_endForFormat),
    _ChalkPatterns.directive('extends', arg: true):
    _directiveMapper(_extendsFormat),
    _ChalkPatterns.directive('start block', arg: true):
    _directiveMapper(_startBlockFormat),
    _ChalkPatterns.directive('end block'): _directiveMapper(_endBlockFormat),
    _ChalkPatterns.directive('block', arg: true):
    _directiveMapper(_blockFormat),
    _ChalkPatterns.directive('include', arg: true):
    _directiveMapper(_partialFormat),
    _ChalkPatterns.comment: _commentFormat,
  };

  MatchMapper _directiveMapper(MatchMapper mapper) {
    return (Match $) {
      return "''';${mapper($)}yield '''";
    };
  }

  String _expression(String exp) {
    var expression = exp;
    final strings = new RegExp(_ChalkPatterns.string).allMatches(expression);
    for (final string in strings) {
      expression = expression.replaceFirst(string[0], '__:STRING:__');
    }
    expression = expression
        .replaceAllMapped(
        new RegExp(_ChalkPatterns.instantiation),
        _instantiationFormat);
    for (final m in strings) {
      final string = m[0].replaceAllMapped(_ChalkPatterns.variable,
          _variableFormat);
      expression = expression
          .replaceFirst('__:STRING:__', string);
    }
    return expression;
  }

  String _variableFormat(Match $) {
    final noEscape = $[1] != null;
    final expression = _expression($[2] ?? $[3]);
    if (noEscape)
      return r'${''$expression''}';
    return r'${$esc(''$expression'')}';
  }

  String _ifFormat(Match $) {
    final expression = _expression($[1]);
    return 'yield* \$if([[$expression, () async* {';
  }

  String _elseIfFormat(Match $) {
    final expression = _expression($[1]);
    return '}], [$expression, () async* {';
  }

  String _elseFormat(_) {
    return '}], [() async* {';
  }

  String _endIfFormat(_) {
    return '}]]);';
  }

  String _instantiationFormat(Match $) {
    return r'$new(#''${$[1]})';
  }

  String _forFormat(Match $) {
    final variable = $[1];
    final expression = _expression($[2]);
    return 'yield* \$for($expression, ($variable) async* {';
  }

  String _endForFormat(_) {
    return '});';
  }

  String _extendsFormat(Match $) {
    _isExtending = true;
    final expression = _expression($[1]);
    _expectsBlock = true;
    return 'yield* \$extends($expression, {';
  }

  String _startBlockFormat(Match $) {
    _expectsBlock = false;
    final expression = _expression($[1]);
    return '$expression: () async* {';
  }

  String _endBlockFormat(_) {
    return '},';
  }

  String _blockFormat(Match $) {
    final expression = _expression($[1]);
    return 'yield* \$block($expression);';
  }

  String _endExtends() {
    return '});';
  }

  String _partialFormat(Match $) {
    final expression = _expression($[1]);
    return 'yield* \$generate($expression);';
  }

  String _commentFormat(Match $) {
    final comment = $[1] ?? $[3];
    final line = $[0];
    return line.replaceFirst(comment, '');
  }
}

class _ChalkPatterns {
  static const curlyExpression =
      r'\{(.*?(\{.*?(\{.*?(\{.*?(\{.*?(\{.*?('
      r'\{.*?(\{.*?(\{.*?(\{.*?\}.*?)*\}.*?'
      r')*\}.*?)*\}.*?)*\}.*?)*\}.*?)*\}.'
      r'*?)*\}.*?)*\}.*?)*)\}';
  static const parensExpression =
      r'(.*?(\(.*?(\(.*?(\(.*?(\(.*?(\(.*?('
      r'\(.*?(\(.*?(\(.*?(\(.*?\).*?)*\).*?'
      r')*\).*?)*\).*?)*\).*?)*\).*?)*\).'
      r'*?)*\).*?)*\).*?)*)';
  static const variable = r'\$(!!)?(?:(\w+)|''$curlyExpression'r')';
  static const instantiation = r'\bnew\s*([\w.]+)';
  static const string = r"""('{3}|"{3}|['"])((?:"""'$variable'r'|.)*?)\1';
  static const forLoop = r'@\s*for\s*\(\s*(\w+)\s*in\s*''$parensExpression\\)';
  static const comment = r"""^(?:(\/\/.*)|(?:('''|"""r'''"""|'|").*?\2|.)+?($|\/\/.*))''';

  static directive(String directive, {bool arg: false}) {
    return r'@\s*''${directive.replaceAll(' ', r'\s*')}'
        + (!arg ? '' : r'\s*''\\($parensExpression\\)');
  }
}

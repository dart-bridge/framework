part of bridge.view;

class ExpressionParser {
  Queue<List<String>> _methodArgumentLists = new Queue();

  Future<String> parse(String template, [Map<String, dynamic> variables]) async {
    var toBeEvaluated = '''
    import 'dart:isolate';
    import 'dart:async';
    var port;
    class Responder {
      request(name) {
        var completer = new Completer();
        () async {
          var returnPort = new ReceivePort();
          port.send({'request': name, 'port':returnPort.sendPort});
          completer.complete(returnPort.first);
        }();
        return completer.future;
      }
      call() async => {'response':"""${_transformVarsToRequests(template)}"""};
    }
    main(a, p) async {
      port = p[0];
      try {
        port.send(await new Responder()());
      } catch (e) {
        p[1].send(e.toString());
      }
    }
    ''';

    return _startConversation(toBeEvaluated, variables == null ? {} : variables);
  }

  String _transformVarsToRequests(String template) {
    var varMatcher = new RegExp(r'''([A-Za-z_][\w.]*)(?=(?:[^"']*['"][^"']*['"])*[^"']*$)''');
    var bracesMatcher = new RegExp(r'\$(?:{(.*?)}|([A-Za-z_][\w]*))');
    var accessorMatcher = new RegExp(r'''\[\s*(?:(\d+)|(['"])([^]*?)\2)\s*]''');
    var methodMatcher = new RegExp(r'\b\(([^]*?)\)');
    template = template.replaceAll(r'\$', r'\$\');
    template = template.replaceAllMapped(bracesMatcher, (brace) {
      String content = brace[1] == null ? brace[2] : brace[1];
      var parsedContent = content.replaceAllMapped(accessorMatcher, (m) {
        if (m[2] == null)
          return '.__listAccess.${m[1]}';
        return '.__mapAccess.${m[3]}';
      }).replaceAllMapped(methodMatcher, (m) {
        _methodArgumentLists.add(m[1]
        .split(',')
        .map((s) => s.trim())
        .where((s) => s != '')
        .toList());
        return '.__methodCall';
      }).replaceAllMapped(varMatcher, (m) {
        return '(await request("${m[1]}"))';
      });
      return '\${$parsedContent}';
    });
    template = template.replaceAll(r'\$\', r'\$');
    return template;
  }

  Future<String> _startConversation(String template, Map<String, dynamic> data) async {
    var port = new ReceivePort();
    var completer = new Completer();
    var errors = new ReceivePort()
      ..first.then((e) {
      if (!completer.isCompleted)
        completer.completeError(e);
    });

    var isolate = await Isolate.spawnUri(
        Uri.parse(
            'data:application/dart;charset=utf-8,'
            '${Uri.encodeComponent(template)}'),
        [],
        [port.sendPort, errors.sendPort]);

    var exit = new ReceivePort()
      ..first.then((_) {
      if (!completer.isCompleted)
        completer.complete(null);
    });

    isolate.addErrorListener(errors.sendPort);
    isolate.addOnExitListener(exit.sendPort);

    port.listen((Map message) async {
      if (message['response'] != null)
        return completer.complete(message['response']);
      if (message['request'] != null) {
        SendPort returnPort = message['port'];
        var expression = message['request'];
        returnPort.send(await _getValue(expression, data));
      }
    });
    return completer.future;
  }

  Future _getValue(String expression, Map data) async {
    var segments = expression.split('.');
    var pointer = data.containsKey(segments[0])
    ? data[segments.removeAt(0)]
    : _getGlobalEntity(segments.removeAt(0));
    var nextIsList = false;
    var nextIsMap = false;
    var stringStringMatcher = new RegExp(r'''^['"]([^]*)['"]$''');
    var stringNumMatcher = new RegExp(r'''^[\d.]+$''');
    for (var segment in segments) {
      if (segment == '__methodCall') {
        var args = _methodArgumentLists.removeFirst();
        args = await Future.wait(args.map((arg) async {
          if (stringStringMatcher.hasMatch(arg))
            return arg.replaceFirstMapped(stringStringMatcher, (m) => m[1]);
          if (stringNumMatcher.hasMatch(arg))
            return arg.contains('.') ? double.parse(arg) : int.parse(arg);
          return await _getValue(arg, data);
        }));
        if (pointer == null) throw 'Uncallable';
        pointer = (reflect(pointer) as ClosureMirror).apply(args).reflectee;
        continue;
      }
      if (segment == '__listAccess') {
        nextIsList = true;
        continue;
      }
      if (segment == '__mapAccess') {
        nextIsMap = true;
        continue;
      }
      if (nextIsMap) {
        nextIsMap = false;
        pointer = pointer[segment];
        continue;
      }
      if (nextIsList) {
        nextIsList = false;
        pointer = pointer[int.parse(segment)];
        continue;
      }
      pointer = reflect(pointer).getField(new Symbol(segment)).reflectee;
    }
    return pointer;
  }

  Object _getGlobalEntity(String name) {
    var symbol = new Symbol(name);
    MethodMirror method = currentMirrorSystem().libraries.values
    .expand((l) => l.declarations.values)
    .where((d) => d.isTopLevel && !d.isPrivate)
    .firstWhere((d) => d.simpleName == symbol, orElse: () => null);
    if (method == null) return null;
    return (method.owner as LibraryMirror).getField(symbol).reflectee;
  }
}
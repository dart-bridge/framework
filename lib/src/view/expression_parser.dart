part of bridge.view;

class ExpressionParser {
  final String _expression;

  ExpressionParser(String this._expression);

  String parse(Map<String, dynamic> variables) {
    ExpressionFactory ef = new ExpressionFactory();

    ELContext ctx = new ELContext.mapper(
        functionMapper: new GlobalFunctionMapper()
    );
    for (var variable in variables.keys) {
      ctx.variableMapper.setVariable(variable,
      ef.createVariable(variables[variable]));
    }

    ValueExpression ve = ef.createValueExpression(ctx, _expression, reflectType(String));

    return ve.getValue(ctx);
  }
}

class GlobalFunctionMapper extends FunctionMapper {
  Function resolveFunction(String name) {
    return _allGlobalFunctions().firstWhere(_hasName(name)).reflectee;
  }

  List<ClosureMirror> _allGlobalFunctions() {
    return currentMirrorSystem().libraries.values.expand(_globalFunctionsInLibrary).toList();
  }

  Function _hasName(String name) {
    return (ClosureMirror mirror) => mirror.function.simpleName == new Symbol(name);
  }

  Iterable _globalFunctionsInLibrary(LibraryMirror element) {
    return element.declarations.values
    .where(_isGlobalFunction)
      .map((d) => element.getField(d.simpleName));
  }

  bool _isGlobalFunction(DeclarationMirror element) {
    return element is MethodMirror && (element as MethodMirror).isRegularMethod && element.isTopLevel;
  }
}
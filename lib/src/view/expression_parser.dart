part of bridge.view;

class ExpressionParser {
  final String _expression;

  ExpressionParser(String this._expression);

  String parse(Map<String, dynamic> variables) {
    ExpressionFactory ef = new ExpressionFactory();

    ELContext ctx = new ELContext();
    for (var variable in variables.keys) {
      ctx.variableMapper.setVariable(variable,
      ef.createVariable(variables[variable]));
    }

    ValueExpression ve = ef.createValueExpression(ctx, _expression, reflectType(String));

    return ve.getValue(ctx);
  }
}

part of bridge.database;

const field = 'field';

abstract class Model extends PersistentObject {

  Future save() async {

    _getFields().forEach((field, value) {

      this.setProperty(field, value);
    });

    await super.save();
  }

  Map<String, dynamic> _getFields() {

    var mirror = reflect(this);

    var fieldSymbols = _getModelFieldNames();

    var fieldNames = fieldSymbols.map((s) => MirrorSystem.getName(s));

    return new Map.fromIterables(
        fieldNames,
        fieldSymbols.map((symbol) => mirror.getField(symbol).reflectee)
    );
  }

  List<Symbol> _getModelFieldNames() {

    var model = reflect(this).type;

    var fields = <Symbol>[];

    model.declarations.forEach((symbol, property) {

      if (property.metadata.any((meta) => meta.reflectee == field)) {

        fields.add(symbol);
      }
    });

    return fields;
  }

  String toString() => '${this.runtimeType}(${_getFields()})';

  Map toJson() => _getFields();
}
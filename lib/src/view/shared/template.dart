part of bridge.view.shared;

class Template implements Serializable {
  final String parsed;
  final Map<String, dynamic> data;
  final String asHandlebars;

  Template({String this.parsed: '',
           Map<String, dynamic> this.data: const {},
           String this.asHandlebars: ''});

  factory Template.deserialize(Map<String, dynamic> serialized) {
    return new Template(
        parsed: serialized['parsed'],
        data: serialized['data'],
        asHandlebars: serialized['asHandlebars']
    );
  }

  Map<String, dynamic> serialize() => {
    'parsed': parsed,
    'data': data,
    'asHandlebars': asHandlebars,
  };

  String toString() => parsed;
}

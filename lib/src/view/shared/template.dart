part of bridge.view.shared;

class Template implements Serializable {
  final String parsed;
  final Map<String, dynamic> data;

  Template({String this.parsed: '',
           Map<String, dynamic> this.data: const {}});

  factory Template.deserialize(Map<String, dynamic> serialized) {
    return new Template(
        parsed: serialized['parsed'],
        data: serialized['data']
    );
  }

  Map<String, dynamic> serialize() => {
    'parsed': parsed,
    'data': data,
  };

  String toString() => parsed;
}

part of bridge.view.shared;

class Template {
  final String parsed;
  final Map<String, dynamic> data;

  Template({String this.parsed: '',
           Map<String, dynamic> this.data: const {}});

  String toString() => parsed;
}

part of bridge.view.shared;

class Template {
  final Stream<String> content;
  final Map<String, dynamic> data;

  Template(Stream<String> this.content,
      {Map<String, dynamic> this.data: const {}});
}

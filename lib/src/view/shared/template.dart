part of bridge.view.shared;

class Template {
  final Stream<String> content;
  final Map<String, dynamic> data;

  Template(Stream<String> this.content,
      {Map<String, dynamic> this.data: const {}});

  Future<String> get parsed => content.join('\n');

  Stream<List<int>> get encoded => content.map(UTF8.encode);
}

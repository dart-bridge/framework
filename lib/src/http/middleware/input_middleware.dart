part of bridge.http;

class InputMiddleware {
  call(shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      Input input = await _getInputFor(request);
      return innerHandler(request.change(context: {'input': input}));
    };
  }

  Future<Input> _getInputFor(shelf.Request request) async {
    if (!new RegExp(r'^(GET|HEAD)$').hasMatch(request.method))
      return await new InputParser(request).parse();
    return new Input(Formler.parseUrlEncoded(request.url.query));
  }
}

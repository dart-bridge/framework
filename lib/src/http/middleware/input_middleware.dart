part of bridge.http;

class InputMiddleware {
  call(shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      Input input = await _getInputFor(request);
      return innerHandler(new shelf.Request(
          request.method, request.requestedUri,
          protocolVersion: request.protocolVersion,
          headers: request.headers,
          handlerPath: request.handlerPath,
          context: {'input': input}
            ..addAll(request.context)));
    };
  }

  Future<Input> _getInputFor(shelf.Request request) async {
    if (!new RegExp(r'^(GET|HEAD)$').hasMatch(request.method))
      return await new InputParser(request).parse();
    return new Input(_parseQuery(request.url.query));
  }

  Map<String, dynamic> _parseQuery(String query) {
    if (query == '') return const {};
    return Formler.parseUrlEncoded(query);
  }
}

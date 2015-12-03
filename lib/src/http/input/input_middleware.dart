part of bridge.http;

class InputMiddleware extends Middleware {
  Future<shelf.Response> handle(shelf.Request rawRequest) async {
    return super.handle(
        inject(rawRequest,
        await _getInputFor(rawRequest),
        as: Input));
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

part of bridge.http;

class CsrfMiddleware extends Middleware {
  Future<shelf.Response> handle(shelf.Request request) {
    if (_shouldHaveTokenInput(request))
      _assertTokenIsMatching(request);
    return super.handle(request);
  }

  bool _shouldHaveTokenInput(shelf.Request request) {
    return !new RegExp(r'^(get|head)$', caseSensitive: false)
        .hasMatch(request.method);
  }

  void _assertTokenIsMatching(shelf.Request request) {
    final Input input = getInjection(request, Input);
    if (input == null) return;
    final providedToken = input['_token'];
    final sessionToken = new PipelineAttachment.of(request).session.id;
    if (providedToken != sessionToken)
      throw new TokenMismatchException(request);
  }
}

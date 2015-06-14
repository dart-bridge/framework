part of bridge.http;

class CsrfMiddleware {
  shelf.Handler innerHandler;

  call(shelf.Handler innerHandler) {
    this.innerHandler = innerHandler;
    return _handleRequests;
  }

  bool _shouldContainCsrfToken(shelf.Request req) {
    return !new RegExp(r'^(GET|HEAD)$').hasMatch(req.method);
  }

  _handleRequests(shelf.Request req) async {
    Input input = req.context['input'];
    Session session = req.context['session'];

    if (_shouldContainCsrfToken(req)
    && input['_token'] != session.id)
      return new shelf.Response.forbidden('Token mismatch');

    shelf.Response response = await innerHandler(req);

    return new shelf.Response(
        response.statusCode,
        body: _injectHiddenInputs(session, await response.readAsString()),
        headers: {Cookie.sessionIdKey: session.id}..addAll(response.headers),
        context: response.context);
  }

  String _injectHiddenInputs(Session session, String body) {
    return body.replaceAllMapped(new RegExp(r'<form[^]*?>'), (m) {
      return "${m[0]}<input type='hidden' name='_token' value='${session.id}'>";
    });
  }
}

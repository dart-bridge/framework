part of bridge.http.sessions;

class SessionsMiddleware {
  SessionManager manager;
  shelf.Handler innerHandler;
  shelf.Request request;
  Session session;

  SessionsMiddleware(SessionManager this.manager);

  call(shelf.Handler innerHandler) {
    this.innerHandler = innerHandler;
    return _handleRequests;
  }

  Future<shelf.Response> _handleRequests(shelf.Request req) async {
    request = manager.attachSession(req);
    session = manager.sessionOf(request);
    return _attachSessionToResponse(await innerHandler(request));
  }

  shelf.Response _attachSessionToResponse(shelf.Response response) {
    response = manager.passSession(from: request, to: response);
    if (session.isNew) response = _setSessionCookie(response);
    session.clearOldFlashes();
    return response;
  }

  shelf.Response _setSessionCookie(shelf.Response response) {
    return response.change(headers: {
      'Set-Cookie': new Cookie(Cookie.sessionIdKey, session.id).set()
    });
  }
}

part of bridge.http.sessions;

class SessionsMiddleware extends Middleware {
  final SessionManager manager;

  SessionsMiddleware(this.manager);

  Future<shelf.Response> handle(shelf.Request request) async {
    final session = manager.attachSession(request);
    return super.handle(applySession(request, session))
        .then(_attachSessionToResponse);
  }

  shelf.Response _attachSessionToResponse(shelf.Response response) {
    final session = manager.sessionOf(response);
    if (session.isNew) response = _setSessionCookie(response, session);
    session.clearOldFlashes();
    return response;
  }

  shelf.Response _setSessionCookie(shelf.Response response, Session session) {
    return response.change(headers: {
      'Set-Cookie': new Cookie(Cookie.sessionIdKey, session.id).set()
    });
  }
}
part of bridge.http.sessions;

class SessionManager {
  final Map<String, Session> _sessions = {};

  void open(String id) {
    _sessions[id] = new Session(id);
  }

  Session session(String id) {
    return _sessions[id];
  }

  void close(String id) {
    _sessions.remove(id);
  }

  Session sessionOf(shelf.Message message) {
    if (!hasSession(message)) return null;

    return _sessionOf(message);
  }

  shelf.Message attachSession(shelf.Message message) {
    if (hasSession(message)) return message;

    Session session;
    if (_hasSessionCookie(message))
      session = _loadSessionCookie(message);
    else
      session = _generateSession();

    return message.change(context: {
      'session': session
    });
  }

  Session _loadSessionCookie(shelf.Message message) {
    var cookie = Cookie.parse(message.headers['Cookie'])
    .firstWhere(_isSessionCookie);
    return _sessions[cookie.value]..isNew = false;
  }

  bool _hasSessionCookie(shelf.Message message) {
    if (!message.headers.containsKey('Cookie')) return false;
    var cookies = Cookie.parse(message.headers['Cookie']);
    if (!cookies.any(_isSessionCookie)) return false;
    return _sessions.containsKey(cookies.firstWhere(_isSessionCookie).value);
  }

  bool hasSession(shelf.Message message) {
    return message.context['session'] is Session;
  }

  Session _sessionOf(shelf.Message message) {
    return message.context['session'];
  }

  Session _generateSession() {
    final session = new Session.generate();
    _sessions[session.id] = session;
    return session
      ..isNew = true;
  }

  shelf.Message passSession({shelf.Message from, shelf.Message to}) {
    return to.change(context: {
      'session': from.context['session']
    });
  }

  bool _isSessionCookie(Cookie element) {
    return element.key == Cookie.sessionIdKey;
  }
}

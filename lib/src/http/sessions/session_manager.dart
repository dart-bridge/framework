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

  Session attachSession(shelf.Message message) {
    if (hasSession(message)) return sessionOf(message);

    Session session;
    if (_hasSessionCookie(message))
      session = _loadSessionCookie(message);
    else
      session = _generateSession();

    return session;
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
    return _sessionOf(message) is Session;
  }

  Session _sessionOf(shelf.Message message) {
    return new PipelineAttachment.of(message).session;
  }

  Session _generateSession() {
    var id = _generateId();
    open(id);
    return session(id)
      ..isNew = true;
  }

  String _generateId() {
    var out = '';
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var random = new Random();
    for (var i = 0; i < 128; ++i)
      out += chars[random.nextInt(chars.length - 1)];
    return out;
  }

  bool _isSessionCookie(Cookie element) {
    return element.key == Cookie.sessionIdKey;
  }
}

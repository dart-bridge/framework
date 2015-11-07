part of bridge.tether.shared;

/// **The Tether**
/// This class represents a connection between the server
/// and the client. Similar to HTTP's URIs and methods each
/// request is performed with a key. The convention is keys with
/// camelCase segments separated by dots.
///
/// These segments should try to provide a sense of hierarchy
/// in what part of the app is being interacted with, just like
/// RESTful URIs. For example, if a tether request is used to
/// fetch all posts of a blog, the tether key could look like this:
///
///     posts.all
///
/// More complicated queries should be extracted to their own keys,
/// so that a minimum amount of filtering and sorting is done in
/// the client. For example:
///
///     // On the server
///     tether.listen('topics.mostCommon', (_) {
///       return topicsRepository.getMostCommon();
///     });
///
///     // On the client
///     Map mostCommonTopic = await tether.send('topics.mostCommon');
abstract class Tether {
  /// An object representing the session with the other side.
  Session get session;

  /// Provides a hook for when connection to the other side
  /// has been lost. This could induce a pop up in the
  /// browser or lead to some tear down functionality
  /// on the server.
  Future get onConnectionLost;

  /// Provides a hook for when connection to the other side
  /// has been established.
  Future get onConnectionEstablished;

  /// Sends a request to the other side of the tether. Optionally
  /// takes a value to be sent to the listener.
  ///
  /// Returns the other side's listeners return value as a [Future].
  Future send(String key, [data]);

  /// Attaches a listener to a tether key. The return value of the
  /// listener function is what is sent back as a future value to the
  /// [send] method responsible of the request on the other side.
  ///
  /// Therefore this can not be handled as a stream.
  StreamSubscription listen(String key, Function listener);

  void listenOnce(String key, Function listener);

  /// Sends pings back and fourth so that the [WebSocket] will
  /// not time out.
  void initiatePersistentConnection();

  /// Throw an exception on the other side of the tether. The type of
  /// [exception] should be registered using [exceptionFactories] setter.
  /// If [exception] is not registered it will be cast to a standard
  /// [Exception] on arrival.
  void sendException(String key, Exception exception);

  void modulateBeforeSerialization(modulation(value));
}

abstract class TetherBase implements Tether {
  Messenger _messenger;
  Session _session;
  Set<Function> _returnValueModulators = new Set();

  Session get session => _session;

  Future get onConnectionLost => _messenger.onConnectionEnd;

  Future get onConnectionEstablished => _messenger.onConnectionOpen;

  TetherBase(Session this._session, Messenger this._messenger) {
    _listenForPingPong();
  }

  void _listenForPingPong() {
    this.listen('_pingpong', (_) => _respondToPingPong());
  }

  Future _respondToPingPong() async {
    await new Future.delayed(new Duration(seconds: 5));
    if (!_socketIsOpen) return;
    _sendPingPong();
  }

  bool get _socketIsOpen => _messenger.socketIsOpen;

  Future send(String key, [data]) async {
    data = await _applyModulators(data);
    var message = new Message(key, _session, data);
    Message returnValue = await _send(message);
    if (returnValue.data is Exception)
      throw returnValue.data;
    return returnValue.data;
  }

  void sendException(String key, Exception exception) {
    _send(new Message(key, session, exception));
  }

  Future _send(Message message) {
    return _messenger.send(message);
  }

  StreamSubscription listen(String key, Function listener) {
    return new _TetherStreamSubscription(
        _messenger,
        key,
        _respondToMessage,
        listener);
  }

  void listenOnce(String key, Function listener) {
    _messenger
        .listen(key)
        .first
        .then((m) => _respondToMessage(m, listener))
        .then((_) {
      _messenger.removeListener(key);
    });
  }

  Future _respondToMessage(Message message, Function listener) async {
    session.apply(message.session);
    var returnValue;
    try {
      returnValue = await applyData(message.data, listener);
      send(message.returnToken, returnValue);
    } catch (e) {
      sendException(message.returnToken, e);
    }
  }

  Future applyData(data, Function listener);

  Future _applyModulators(returnValue) async {
    for (var modulator in _returnValueModulators) {
      returnValue = await modulator(returnValue);
    }
    return returnValue;
  }

  void initiatePersistentConnection() {
    _sendPingPong();
  }

  void _sendPingPong() {
    this.send('_pingpong', null);
  }

  void modulateBeforeSerialization(modulation(value)) {
    _returnValueModulators.add(modulation);
  }
}

typedef _MessageResponder(Message message, Function listener);

class _TetherStreamSubscription implements StreamSubscription {
  final Messenger _messenger;
  final String _key;
  final _MessageResponder _responder;
  Function _listener;
  bool _isPaused = false;

  _TetherStreamSubscription(
      this._messenger,
      this._key,
      this._responder,
      this._listener) {
    _messenger.listen(_key).listen(_handle);
  }

  void _handle(Message message) {
    if (isPaused) return;
    _responder(message, _listener);
  }

  @override
  Future asFuture([futureValue]) {
    final completer = new Completer();
    onDone(() => completer.complete(futureValue));
    onError(completer.completeError);
    return completer.future;
  }

  @override
  Future cancel() async {
    _messenger.removeListener(_key);
  }

  @override
  bool get isPaused => _isPaused;

  @override
  void onData(void handleData(data)) {
    _listener = handleData;
  }

  @override
  void onDone(void handleDone()) {
    _messenger.onConnectionEnd.then((_) => handleDone());
  }

  @override
  void onError(Function handleError) {}

  @override
  void pause([Future resumeSignal]) {
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
  }
}

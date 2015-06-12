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
  factory Tether(String token, Messenger messenger) => new _Tether(token, messenger);

  /// The token representing this specific session with the
  /// other side.
  String get token;

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
  void listen(String key, Future listener(data));

  /// Sends pings back and fourth so that the [WebSocket] will
  /// not time out.
  void initiatePersistentConnection();

  /// Set the deserialization factories for the [Exception]s to be
  /// transferable through the [Tether]. If an exception is thrown
  /// on the other side, the [Future] returned from the [send]
  /// method will fail, throwing the corresponding exception from
  /// this map. If the exception thrown is not registered in this
  /// list the exception will be cast to a standard [Exception]
  set exceptionFactories(Map<Type, ExceptionFactory> value);

  /// Throw an exception on the other side of the tether. The type of
  /// [exception] should be registered using [exceptionFactories] setter.
  /// If [exception] is not registered it will be cast to a standard
  /// [Exception] on arrival.
  void sendException(String key, Exception exception);
}

typedef Exception ExceptionFactory(String message);

class _Tether implements Tether {
  Messenger _messenger;
  String _token;
  final Map<Type, ExceptionFactory> _standardExceptionFactories = {
    Exception: (m) => new Exception(m),
    BaseException: (m) => new BaseException(m),
    InvalidArgumentException: (m) => new InvalidArgumentException(m),
    TetherException: (m) => new TetherException(m),
  };
  Map<Type, ExceptionFactory> _exceptionFactories;

  String get token => _token;

  Future get onConnectionLost => _messenger.onConnectionEnd;

  Future get onConnectionEstablished => _messenger.onConnectionOpen;

  _Tether(String this._token, Messenger this._messenger) {
    _exceptionFactories = _standardExceptionFactories;
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
    var message = new Message(key, _token, data);
    Message returnValue = await _send(message);
    if (returnValue.exception != -1)
      throw _reconstructException(returnValue);
    return returnValue.data;
  }

  void sendException(String key, Exception exception) {
    var exceptionIndex = 0;
    if (_exceptionFactories.containsKey(exception.runtimeType))
      exceptionIndex = _exceptionFactories.keys.toList().indexOf(exception.runtimeType);
    var message = new Message(key, token, exception);
    message.exception = exceptionIndex;
    _send(message);
  }

  Future _send(Message message) {
    return _messenger.send(message);
  }

  void listen(String key, Future listener(data)) {
    _messenger.listen(key).listen((m) => _respondToMessage(m, listener));
  }

  Future _respondToMessage(Message message, Future listener(data)) async {
    var returnValue;
    try {
      returnValue = await listener(message.data);
      send(message.returnToken, returnValue);
    } catch (e) {
      sendException(message.returnToken, e);
    }
  }

  Exception _reconstructException(Message message) {
    var index = message.exception;
    if (_exceptionFactories.length <= index)
      index = 0;
    try {
      return _exceptionFactories.values.elementAt(index)(message.data);
    } catch(e) {
      throw new TetherException('Failed to reconstruct ${_exceptionFactories.keys.elementAt(index)}: $e');
    }
  }

  void initiatePersistentConnection() {
    _sendPingPong();
  }

  void _sendPingPong() {
    this.send('_pingpong', null);
  }

  set exceptionFactories(Map<Type, ExceptionFactory> value) {
    _exceptionFactories = new Map.from(_standardExceptionFactories)
      ..addAll(value);
  }
}
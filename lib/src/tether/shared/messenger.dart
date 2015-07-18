part of bridge.tether.shared;

/// This is the manager for sending and receiving messages
/// for a specific [Tether]. This is the actual tether. The [Tether]
/// class is only a wrapper that doesn't expose the entire messages
/// to the public API.
abstract class Messenger {
  final bool socketIsOpen;
  final Future onConnectionEnd;
  final Future onConnectionOpen;

  factory Messenger(SocketInterface socket, Serializer serializer) =>
  new _Messenger(socket, serializer);

  Future<Message> send(Message message);

  Stream<Message> listen(String key);

  void registerStructure(String id, Type serializable, Serializable factory(data));
}

class _Messenger implements Messenger {
  SocketInterface _socket;
  Map<String, StreamController<Message>> _listeners = {};
  Serializer _serializer;

  bool get socketIsOpen => _socket.isOpen;

  Future get onConnectionEnd => _socket.onClose;

  Future get onConnectionOpen => _socket.onOpen;

  _Messenger(SocketInterface this._socket, Serializer this._serializer) {
    _listenOnSocket();
  }

  void _listenOnSocket() {
    _socket.receiver.listen(_onSocketData);
  }

  void _onSocketData(data) {
    Message message = new Message.deserialize(data);
    if (_listenerExistsForKey(message.key))
      _sendMessageToListeners(message);
  }

  bool _listenerExistsForKey(String key) {
    return _listeners.containsKey(key);
  }

  void _sendMessageToListeners(Message message) {
    _listeners[message.key].add(message);
  }

  Stream<Message> listen(String key) {
    _ensureUniqueListener(key);
    return _registerListener(key).stream.asyncMap(_deserializeData);
  }

  StreamController<Message> _registerListener(String key) {
    return _listeners[key] = new StreamController<Message>();
  }

  void _ensureUniqueListener(String key) {
    if (_listenerExistsForKey(key))
      throw new SocketOccupiedException(
          'Socket [$key] has already been listened to'
      );
  }

  Future<Message> send(Message message) async {
    message.data = _serializer.serialize(message.data);
    _socket.send(message.serialized);
    return _returnMessage(message);
  }

  Future<Message> _returnMessage(Message message) {
    return listen(message.returnToken).first;
  }

  void close(String key) {
    if (!_listenerExistsForKey(key)) return;
    _listeners[key].close();
    _listeners.remove(key);
  }

  void registerStructure(String id, Type serializable, Serializable factory(data)) {
    _serializer.registerStructure(id, serializable, factory);
  }

  Message _deserializeData(Message message) {
    message.data = _serializer.deserialize(message.data);
    return message;
  }
}

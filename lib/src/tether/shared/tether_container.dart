part of bridge.tether;

class TetherContainer {

  SocketInterface _socket;

  Map<String, StreamController<Message>> _listeners = {};

  bool get _socketIsOpen => _socket.isOpen;

  Future get onConnectionEnd => _socket.onClose;

  TetherContainer(SocketInterface this._socket) {

    _socket.receiver.listen((data) {

      Message message = new Message.deserialize(data);

      if (_listeners.containsKey(message.key)) {

        _listeners[message.key].add(message);
      }
    });
  }

  Stream<Message> listen(String key) {

    if (_listeners.containsKey(key))
      throw new SocketOccupiedException('Socket [$key] has already been listened to');

    var controller = new StreamController<Message>();

    _listeners[key] = controller;

    return controller.stream;
  }

  Future<Message> send(Message message) async {

    _socket.send(message.serialized);

    Message returnValue = await listen(message.returnToken).first;

    return returnValue;
  }

  void close(String key) {

    if (!_listeners.containsKey(key)) return;

    _listeners[key].close();

    _listeners.remove(key);
  }
}
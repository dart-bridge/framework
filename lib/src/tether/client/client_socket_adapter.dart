part of bridge.tether.client;

/// Adapter for the client side [dart.dom.html.WebSocket],
/// implementing the [SocketInterface].
class ClientSocketAdapter implements SocketInterface {
  WebSocket _socket;
  StreamController _controller = new StreamController();

  ClientSocketAdapter(WebSocket this._socket) {
    _listen();
  }

  _listen() {
    _socket.onMessage.listen((MessageEvent event) {
      _controller.add(event.data);
    });
  }

  void send(data) => _socket.send(data);

  Stream get receiver => _controller.stream;

  bool get isOpen => _socket.readyState == WebSocket.OPEN;

  Future get onClose => _socket.onClose.first;

  Future get onOpen => _socket.onOpen.first;
}
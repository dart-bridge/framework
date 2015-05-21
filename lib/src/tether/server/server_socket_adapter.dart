part of bridge.tether.server;

class ServerSocketAdapter implements SocketInterface {

  WebSocket _socket;

  ServerSocketAdapter(WebSocket this._socket);

  Stream get receiver => _socket;

  void send(data) => _socket.add(data);

  static Tether makeTether(WebSocket socket, String token) {

    socket.add(new Message('_handshake', token, null).serialized);

    TetherContainer container = new TetherContainer(
        new ServerSocketAdapter(socket)
    );

    return new Tether(token, container);
  }

  bool get isOpen => _socket.readyState == WebSocket.OPEN;

  Future get onClose => _socket.done;
}
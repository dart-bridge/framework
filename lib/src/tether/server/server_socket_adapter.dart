part of bridge.tether;

/// Adapter for the server side [dart.io.WebSocket],
/// implementing the [SocketInterface].
class ServerSocketAdapter implements SocketInterface {
  WebSocket _socket;

  ServerSocketAdapter(WebSocket this._socket);

  Stream get receiver => _socket;

  void send(data) => _socket.add(data);

  bool get isOpen => _socket.readyState == WebSocket.OPEN;

  Future get onClose => _socket.done;

  Future get onOpen async => await null;
}
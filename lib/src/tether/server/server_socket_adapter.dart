part of bridge.tether;

/// Adapter for the server side [dart.io.WebSocket],
/// implementing the [SocketInterface].
class ServerSocketAdapter implements SocketInterface {
  http_parser.CompatibleWebSocket _socket;

  ServerSocketAdapter(http_parser.CompatibleWebSocket this._socket);

  Stream get receiver => _socket;

  void send(data) => _socket.add(data);

  bool get isOpen => true;

  Future get onClose => _socket.done;

  Future get onOpen async => await null;
}
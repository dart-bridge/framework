part of bridge.tether;

class ServerTetherMaker {
  static Tether makeTether(http_parser.CompatibleWebSocket socket, String token) {
    _sendToken(socket, token);
    return new Tether(token, _makeMessenger(socket));
  }

  static Messenger _makeMessenger(http_parser.CompatibleWebSocket socket) {
    return new Messenger(new ServerSocketAdapter(socket), new SerializationManager());
  }

  static _sendToken(http_parser.CompatibleWebSocket socket, String token) {
    socket.add(new Message('_handshake', token, null).serialized);
  }
}

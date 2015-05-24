part of bridge.tether;

class ServerTetherMaker {
  static Tether makeTether(WebSocket socket, String token) {
    _sendToken(socket, token);
    return new Tether(token, _makeMessenger(socket));
  }

  static Messenger _makeMessenger(WebSocket socket) {
    return new Messenger(new ServerSocketAdapter(socket));
  }

  static _sendToken(WebSocket socket, String token) {
    socket.add(new Message('_handshake', token, null).serialized);
  }
}

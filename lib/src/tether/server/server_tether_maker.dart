part of bridge.tether;

class ServerTetherMaker {
  static Tether makeTether(Container container,
      http_parser.CompatibleWebSocket socket, http.Session session) {
    _sendSession(socket, session);
    return new Tether.make(container, session, _makeMessenger(socket));
  }

  static Messenger _makeMessenger(http_parser.CompatibleWebSocket socket) {
    return new Messenger(new ServerSocketAdapter(socket));
  }

  static _sendSession(http_parser.CompatibleWebSocket socket,
      http.Session session) {
    socket.add(new Message('_handshake', session, null).serialized);
  }
}

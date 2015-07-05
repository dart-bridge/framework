part of bridge.tether.client;

class ClientTetherMaker {
  static Future<Tether> makeTether() async {
    WebSocket socket = await _openSocket();
    Tether tether = await _handshake(socket);
    new DefaultStructures()(tether);
    return tether..initiatePersistentConnection();
  }

  static Future<WebSocket> _openSocket() async {
    WebSocket socket = _makeSocket();
    await socket.onOpen.first;
    return socket;
  }

  static WebSocket _makeSocket() {
    return new WebSocket(
        'ws://${window.location.hostname}:${window.location.port}/');
  }

  static Future<Tether> _handshake(WebSocket socket) async {
    Messenger messenger = new Messenger(new ClientSocketAdapter(socket), new SerializationManager());
    Message handshakeMessage = await messenger.listen('_handshake').first;
    return new Tether(handshakeMessage.token, messenger);
  }
}

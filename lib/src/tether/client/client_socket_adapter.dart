part of bridge.tether.client;

class ClientSocketAdapter implements SocketInterface {

  WebSocket _socket;

  StreamController _controller = new StreamController();

  ClientSocketAdapter(WebSocket this._socket) {

    _socket.onMessage.listen((MessageEvent event) {

      _controller.add(event.data);
    });
  }

  void send(data) => _socket.send(data);

  Stream get receiver  => _controller.stream;

  static Future<Tether> makeTether() async {

    WebSocket socket = await new WebSocket(
        'ws://${window.location.hostname}:${window.location.port}/'
    );

    await socket.onOpen.first;

    TetherContainer container = new TetherContainer(new ClientSocketAdapter(socket));

    Message handshakeMessage = await container.listen('_handshake').first;

    var tether = new Tether(handshakeMessage.token, container);

//    tether.initiatePersistentConnection();

    return tether;
  }

  bool get isOpen => _socket.readyState == WebSocket.OPEN;

  Future get onClose => _socket.onClose.first;
}

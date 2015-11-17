part of bridge.tether.shared;

class IsolateTether extends TetherBase {
  IsolateTether._(Session session, Messenger messenger)
    : super(session, messenger);

  static Future<Tether> client(SendPort port) async {
    final socket = new IsolateSocketAdapter.connect(port);
    final messenger = new Messenger(socket);
    final session = new Session.generate();
    await socket.onOpen;
    messenger.send(new Message('_handshake', session, null));
    return new IsolateTether._(session, messenger);
  }

  static Future<Tether> spawn(void body(SendPort port)) {
    return _server(new IsolateSocketAdapter.spawn(body));
  }

  static Future<Tether> spawnUri(Uri uri, [Iterable<String> arguments = const []]) {
    return _server(new IsolateSocketAdapter.spawnUri(uri, arguments));
  }

  static Future<Tether> _server(SocketInterface socket) async {
    final messenger = new Messenger(socket);
    final handshakeMessage = await messenger.listen('_handshake').first;
    return new IsolateTether._(handshakeMessage.session, messenger);
  }

  Future applyData(data, Function listener) async {
    if (data == null)
      return listener();
    else
      return listener(data);
  }
}

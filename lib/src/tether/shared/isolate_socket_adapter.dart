part of bridge.tether.shared;

typedef Future<Isolate> _IsolateGenerator(SendPort message, SendPort onExit);

class IsolateSocketAdapter implements SocketInterface {
  final Completer _onClose = new Completer();
  final Completer _onOpen = new Completer();
  final StreamController _controller = new StreamController();
  SendPort _sender;

  IsolateSocketAdapter._server(_IsolateGenerator generator) {
    _start(generator);
  }

  IsolateSocketAdapter.connect(SendPort port) {
    _connect(port);
  }

  factory IsolateSocketAdapter.spawn(void body(SendPort port)) {
    return new IsolateSocketAdapter._server((message, onExit) {
      return Isolate.spawn(body, message, onExit: onExit);
    });
  }

  factory IsolateSocketAdapter.spawnUri(Uri uri, Iterable<String> arguments) {
    return new IsolateSocketAdapter._server((message, onExit) {
      return Isolate.spawnUri(uri, arguments.toList(), message, onExit: onExit);
    });
  }

  Future _start(_IsolateGenerator generator) async {
    final handshaker = new ReceivePort();
    final onExit = new ReceivePort();
    onExit.first.then(_onClose.complete);
    handshaker.first.then(_receiveHandshake);
    await generator(handshaker.sendPort, onExit.sendPort);
  }

  Future _connect(SendPort handshaker) async {
    final mainReceiver = new ReceivePort();
    final expectsMainSend = new ReceivePort();
    expectsMainSend.first.then((SendPort mainSender) {
      _init(mainSender, mainReceiver);
    });
    handshaker.send([mainReceiver.sendPort, expectsMainSend.sendPort]);
  }

  _receiveHandshake(List<SendPort> ports) {
    final mainReceiver = new ReceivePort();
    final mainSender = ports[0];
    final expectsMainSend = ports[1];
    expectsMainSend.send(mainReceiver.sendPort);
    _init(mainSender, mainReceiver);
  }

  void _init(SendPort mainSend, ReceivePort mainReceive) {
    mainReceive.listen(_controller.add);
    _sender = mainSend;
    _onOpen.complete();
  }

  void send(data) {
    _sender.send(data);
  }

  Stream get receiver => _controller.stream;

  bool get isOpen => _onOpen.isCompleted;

  Future get onClose => _onClose.future;

  Future get onOpen => _onOpen.future;
}

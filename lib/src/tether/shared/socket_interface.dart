part of bridge.tether.shared;

/// This provides a common interface to be used
/// both on the server and the client. The [ServerSocketAdapter]
/// and the [ClientSocketAdapter] both implement this.
abstract class SocketInterface {

  void send(data);

  Stream get receiver;

  bool get isOpen;

  Future get onClose;
}
part of bridge.tether;

abstract class SocketInterface {

  void send(data);

  Stream get receiver;

  bool get isOpen;

  Future get onClose;
}
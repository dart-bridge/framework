part of bridge.tether.shared;

class SocketOccupiedException extends InvalidArgumentException {

  SocketOccupiedException([String message = 'This socket has already been listened to.']) : super(message);
}
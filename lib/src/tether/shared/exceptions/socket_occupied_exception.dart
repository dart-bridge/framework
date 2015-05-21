part of bridge.tether;

class SocketOccupiedException extends InvalidArgumentException {

  SocketOccupiedException([String message = 'This socket has already been listened to.']) : super(message);
}
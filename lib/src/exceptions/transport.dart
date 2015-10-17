part of bridge.exceptions.shared;

void registerExceptionsTransport() {
  Serializer.instance.register('BaseException', BaseException,
      serialize: (BaseException e) => e.message,
      deserialize: (String m) => new BaseException(m));
  Serializer.instance.register('InvalidArgumentException', InvalidArgumentException,
      serialize: (InvalidArgumentException e) => e.message,
      deserialize: (String m) => new InvalidArgumentException(m));
}

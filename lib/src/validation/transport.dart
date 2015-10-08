part of bridge.validation.shared;

void registerValidationTransport() {
  Serializer.instance.register('ValidationException', ValidationException,
      serialize: (ValidationException o) => o.message,
      deserialize: (String message) => new ValidationException(message));
}
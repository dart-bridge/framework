part of bridge.core;

/// An [Exception] thrown when an instantiation failed. It is thrown,
/// caught and rethrown to that we can see the stack of failing
/// instantiations.
///
/// If one class depends on another, that depends on a third one, and that
/// third one fails to instantiate, we can trace what class was being
/// requested, and why the instantiation failed.
class ContainerException extends BaseException {

  ContainerException(Type type, [error]) : super('Cannot resolve $type' +
                                                 ((error != null)
                                                 ? ' because:\n$error'
                                                 : ''));
}
part of bridge.http;

abstract class Middleware {
  static const _attachmentKey = r'$bridge.http.RequestAttachment';
  shelf.Handler _inner;

  shelf.Handler call(shelf.Handler inner) {
    this._inner = inner;
    return handle;
  }

  Future<shelf.Response> handle(shelf.Request request) async {
    return await _inner(request);
  }

  shelf.Request attach(shelf.Request request, RequestAttachment attachment) {
    final RequestAttachment old = request.context[_attachmentKey]
        ?? const RequestAttachment.empty();
    return request.change(context: {
      _attachmentKey: old.apply(attachment)
    });
  }

  shelf.Request inject(shelf.Request request, Object instance, {Type as}) {
    return attach(request, new RequestAttachment(inject: {
      as ?? instance.runtimeType: instance
    }));
  }

  shelf.Request convert(shelf.Request request, Type type, conversion(value)) {
    return attach(request, new RequestAttachment(convert: {
      type: conversion
    }));
  }
}

class RequestAttachment {
  final Map<Type, Object> inject;
  final Map<Type, Function> convert;

  const RequestAttachment({
  this.inject: const {},
  this.convert: const {}
  });

  const RequestAttachment.empty()
      : inject = const {},
        convert = const {};

  RequestAttachment apply(RequestAttachment other) {
    return new RequestAttachment(
        inject: new Map.from(inject)
          ..addAll(other.inject),
        convert: new Map.from(convert)
          ..addAll(other.convert)
    );
  }
}

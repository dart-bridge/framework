part of bridge.http;

abstract class Middleware {
  shelf.Handler _inner;

  shelf.Handler call(shelf.Handler inner) {
    this._inner = inner;
    return handle;
  }

  Future<shelf.Response> handle(shelf.Request request) {
    return _handle(request).then(_reattach(new PipelineAttachment.of(request)));
  }

  Future<shelf.Response> _handle(shelf.Request request) async {
    return await _inner(request);
  }

  Function _reattach(PipelineAttachment attachment) {
    return (shelf.Response response) {
      return attachIfEmpty(response, attachment);
    };
  }

  shelf.Message attach(shelf.Message message, PipelineAttachment attachment) {
    return message.change(context: {
      PipelineAttachment._contextKey: new PipelineAttachment.of(message)
          .apply(attachment)
    });
  }

  shelf.Message attachIfEmpty(shelf.Message message, PipelineAttachment attachment) {
    return message.change(context: {
      PipelineAttachment._contextKey: new PipelineAttachment.of(message)
          .applyIfEmpty(attachment)
    });
  }

  shelf.Message inject(shelf.Message message, Object instance, {Type as}) {
    return attach(message, new PipelineAttachment(inject: {
      as ?? instance.runtimeType: instance
    }));
  }

  dynamic getInjection(shelf.Request request, Type injection) =>
      new PipelineAttachment.of(request).inject[injection];

  shelf.Message convert(shelf.Message message, Type type, conversion(value)) {
    return attach(message, new PipelineAttachment(convert: {
      type: conversion
    }));
  }

  shelf.Message applySession(shelf.Message message, Session session) {
    return attach(message, new PipelineAttachment(session: session));
  }
}

class PipelineAttachment {
  static const _contextKey = r'$bridge.http.RequestAttachment';
  final Map<Type, Object> inject;
  final Map<Type, Function> convert;
  final Session session;

  const PipelineAttachment({
  this.inject: const {},
  this.convert: const {},
  this.session
  });

  factory PipelineAttachment.of(shelf.Message message) {
    return message.context[_contextKey] ?? const PipelineAttachment.empty();
  }

  const PipelineAttachment.empty()
      : inject = const {},
        convert = const {},
        session = null;

  PipelineAttachment apply(PipelineAttachment other) {
    return new PipelineAttachment(
        inject: new Map.from(inject)
          ..addAll(other.inject),
        convert: new Map.from(convert)
          ..addAll(other.convert),
        session: other.session ?? session
    );
  }

  PipelineAttachment applyIfEmpty(PipelineAttachment other) {
    final oldInject = new Map.from(inject);
    for (final injectKey in other.inject.keys) {
      oldInject.putIfAbsent(injectKey, () => other.inject[injectKey]);
    }
    final oldConvert = new Map.from(convert);
    for (final convertKey in other.convert.keys) {
      oldConvert.putIfAbsent(convertKey, () => other.convert[convertKey]);
    }
    return new PipelineAttachment(
        inject: oldInject,
        convert: oldConvert,
        session: session ?? other.session
    );
  }
}

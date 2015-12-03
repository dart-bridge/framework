part of bridge.http;

abstract class RouterAttachments<T> {
  T named(String name);

  T inject(Object object, {Type as});

  T ignoreMiddleware(middleware);

  T withMiddleware(middleware);
}
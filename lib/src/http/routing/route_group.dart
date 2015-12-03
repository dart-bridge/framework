part of bridge.http;

class RouteGroup implements RouterAttachments<RouteGroup> {
  final Set<Route> _routes;

  RouteGroup(Set<Route> this._routes);

  RouteGroup named(String name) {
    for (final route in _routes)
      route.name = '$name.${route.name}';
    return this;
  }

  RouteGroup inject(Object object, {Type as}) {
    for (final route in _routes)
      route._shouldInject[as ?? object.runtimeType] = object;
    return this;
  }

  RouteGroup ignoreMiddleware(middleware) {
    for (final route in _routes)
      route.ignoreMiddleware(middleware);
    return this;
  }

  RouteGroup withMiddleware(middleware) {
    for (final route in _routes)
      route.withMiddleware(middleware);
    return this;
  }
}
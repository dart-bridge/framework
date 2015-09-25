part of bridge.http;

abstract class RouteBuilder {
  factory RouteBuilder(Route route) => new _RouteBuilder(route);

  RouteBuilder named(String name);

  RouteBuilder inject(Object value, {Type as});
}

abstract class Router {
  Set<Route> _routes;

  factory Router() => new _Router();

  RouteBuilder get(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  RouteBuilder post(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  RouteBuilder put(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  RouteBuilder update(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  RouteBuilder patch(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  RouteBuilder delete(String route,
      Function handler,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});

  void resource(String route,
      Object controller,
      {String name,
      bool middleware,
      List<Type> ignoreMiddleware});
}

class _Router implements Router {
  Set<Route> _routes = new Set();

  RouteBuilder _route(String method,
      String route,
      Function handler,
      String name,
      bool middleware,
      List<Type> ignoreMiddleware) {
    middleware = middleware == null ? true : middleware;
    ignoreMiddleware = ignoreMiddleware == null ? [] : ignoreMiddleware;
    final newRoute = new Route(
        method,
        route,
        handler,
        name: name,
        useMiddleware: middleware,
        ignoredMiddleware: ignoreMiddleware);
    _routes.add(newRoute);
    return new RouteBuilder(newRoute);
  }

  RouteBuilder delete(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('DELETE', route, handler, name, middleware, ignoreMiddleware);

  RouteBuilder get(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('GET', route, handler, name, middleware, ignoreMiddleware);

  RouteBuilder patch(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('PATCH', route, handler, name, middleware, ignoreMiddleware);

  RouteBuilder post(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('POST', route, handler, name, middleware, ignoreMiddleware);

  RouteBuilder put(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('PUT', route, handler, name, middleware, ignoreMiddleware);

  RouteBuilder update(String route,
      Function handler,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) =>
      _route('UPDATE', route, handler, name, middleware, ignoreMiddleware);

  void resource(String route,
      Object controller,
      {String name,
      bool middleware, List<Type> ignoreMiddleware}) {
    var controllerMirror = reflect(controller);
    var baseName = name == null ? route.split('/').removeLast() : name;
    _restfulResource(
        route, controllerMirror, baseName, middleware, ignoreMiddleware);
  }

  void _restfulResource(String route, InstanceMirror controller, String name,
      bool middleware, List<Type> ignoreMiddleware) {
    if (controller.type.declarations.containsKey(#index))
      _route('GET', '$route', controller
          .getField(#index)
          .reflectee, '$name.index', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#create))
      _route('GET', '$route/create', controller
          .getField(#create)
          .reflectee, '$name.create', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#store))
      _route('POST', '$route', controller
          .getField(#store)
          .reflectee, '$name.store', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#show))
      _route('GET', '$route/:id', controller
          .getField(#show)
          .reflectee, '$name.show', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#edit))
      _route('GET', '$route/:id/edit', controller
          .getField(#edit)
          .reflectee, '$name.edit', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#update))
      _route('PUT', '$route/:id', controller
          .getField(#update)
          .reflectee, '$name.update', middleware, ignoreMiddleware);
    if (controller.type.declarations.containsKey(#destroy))
      _route('DELETE', '$route/:id', controller
          .getField(#destroy)
          .reflectee, '$name.destroy', middleware, ignoreMiddleware);
  }
}

class _RouteBuilder implements RouteBuilder {
  Route _route;

  _RouteBuilder(Route this._route);

  RouteBuilder named(String name) {
    _route.name = name;
    return this;
  }

  RouteBuilder inject(Object value, {Type as}) {
    _route._shouldInject[as ?? value.runtimeType] = value;
    return this;
  }
}

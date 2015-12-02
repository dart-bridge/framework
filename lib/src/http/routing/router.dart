part of bridge.http.shared;

abstract class Router {
  Set<Route> _routes;

  factory Router({String base: '',
  List<Type> ignoreMiddleware,
  List<Type> appendMiddleware}) =>
      new BaseRouter(base, ignoreMiddleware ?? [], appendMiddleware ?? []);

  RouteGroup group(String prefix, group());

  Route get(String route, Function handler);

  Route post(String route, Function handler);

  Route put(String route, Function handler);

  Route update(String route, Function handler);

  Route patch(String route, Function handler);

  Route delete(String route, Function handler);
}

class BaseRouter implements Router {
  Set<Route> _routes = new Set();
  final List<Type> _ignoredMiddleware;
  final List<Type> _appendedMiddleware;
  String _base;

  BaseRouter(String this._base,
      List<Type> this._ignoredMiddleware,
      List<Type> this._appendedMiddleware);

  Route makeRoute(String method,
      String route,
      Function handler,
      [String name]) {
    final newRoute = new Route(method, _prefixRoute(route), handler,
        name: name,
        ignoreMiddleware: _ignoredMiddleware.toList(),
        appendMiddleware: _appendedMiddleware.toList());
    _routes.add(newRoute);
    return newRoute;
  }

  String _prefixRoute(String route) {
    return '$_base/$route'.split('/').where((s) => s != '').join('/');
  }

  Route delete(String route, Function handler) =>
      makeRoute('DELETE', route, handler);

  Route get(String route, Function handler) =>
      makeRoute('GET', route, handler);

  Route patch(String route, Function handler) =>
      makeRoute('PATCH', route, handler);

  Route post(String route, Function handler) =>
      makeRoute('POST', route, handler);

  Route put(String route, Function handler) =>
      makeRoute('PUT', route, handler);

  Route update(String route, Function handler) =>
      makeRoute('UPDATE', route, handler);

  RouteGroup group(String prefix, group()) {
    final oldBase = _base;
    final oldRoutes = _routes;
    _routes = new Set();
    _base = '$oldBase/$prefix';
    group();
    _base = oldBase;
    final routeGroup = new RouteGroup(_routes);
    _routes = oldRoutes..addAll(_routes);
    return routeGroup;
  }
}
part of bridge.http;

abstract class Router {
  Set<Route> _routes;

  factory Router({String base: '',
  List<Type> ignoreMiddleware,
  List<Type> appendMiddleware}) =>
      new _Router(base, ignoreMiddleware ?? [], appendMiddleware ?? []);

  RouteGroup group(String prefix, group());

  Route get(String route, Function handler);

  Route post(String route, Function handler);

  Route put(String route, Function handler);

  Route update(String route, Function handler);

  Route patch(String route, Function handler);

  Route delete(String route, Function handler);

  void resource(String route, Object controller);
}

class _Router implements Router {
  Set<Route> _routes = new Set();
  final List<Type> _ignoredMiddleware;
  final List<Type> _appendedMiddleware;
  String _base;

  _Router(String this._base,
      List<Type> this._ignoredMiddleware,
      List<Type> this._appendedMiddleware);

  Route _route(String method,
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
      _route('DELETE', route, handler);

  Route get(String route, Function handler) =>
      _route('GET', route, handler);

  Route patch(String route, Function handler) =>
      _route('PATCH', route, handler);

  Route post(String route, Function handler) =>
      _route('POST', route, handler);

  Route put(String route, Function handler) =>
      _route('PUT', route, handler);

  Route update(String route, Function handler) =>
      _route('UPDATE', route, handler);

  void resource(String route, Object controller) {
    final controllerMirror = reflect(controller);
    final name = route.split('/').removeLast();
    _restfulResource(route, controllerMirror, name);
  }

  void _restfulResource(String route, InstanceMirror controller, String name) {
    if (controller.type.declarations.containsKey(#index))
      _route('GET', '$route', controller
          .getField(#index)
          .reflectee, '$name.index');
    if (controller.type.declarations.containsKey(#create))
      _route('GET', '$route/create', controller
          .getField(#create)
          .reflectee, '$name.create');
    if (controller.type.declarations.containsKey(#store))
      _route('POST', '$route', controller
          .getField(#store)
          .reflectee, '$name.store');
    if (controller.type.declarations.containsKey(#show))
      _route('GET', '$route/:id', controller
          .getField(#show)
          .reflectee, '$name.show');
    if (controller.type.declarations.containsKey(#edit))
      _route('GET', '$route/:id/edit', controller
          .getField(#edit)
          .reflectee, '$name.edit');
    if (controller.type.declarations.containsKey(#update))
      _route('PUT', '$route/:id', controller
          .getField(#update)
          .reflectee, '$name.update');
    if (controller.type.declarations.containsKey(#destroy))
      _route('DELETE', '$route/:id', controller
          .getField(#destroy)
          .reflectee, '$name.destroy');
  }

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
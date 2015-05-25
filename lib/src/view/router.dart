part of bridge.view;

abstract class Router {
  Function notFoundHandler;

  factory Router() => new _Router();

  void route(String method, String route, Function handler);

  void all(Function handler);

  void get(String route, Function handler);

  void post(String route, Function handler);

  void put(String route, Function handler);

  void patch(String route, Function handler);

  void update(String route, Function handler);

  void delete(String route, Function handler);

  Route match(String method, String uri);
}

class _Router implements Router {
  final _routes = <Route>[];
  Function notFoundHandler;
  Function _spaHandler;

  void route(String method, String route, Function handler) {
    _routes.add(new Route(method, route, handler));
  }

  Route match(String method, String uri) {
    for (var route in _routes)
      if (route.matches(method, uri)) return route;

    if (_spaHandler != null && method == 'GET') return new Route(method, uri, _spaHandler);

    throw new InvalidArgumentException('[$uri] matches no routes.');
  }

  void all(Function handler) {
    _spaHandler = handler;
  }

  void get(String route, Function handler) => this.route('GET', route, handler);

  void post(String route, Function handler) => this.route('POST', route, handler);

  void put(String route, Function handler) => this.route('PUT', route, handler);

  void delete(String route, Function handler) => this.route('DELETE', route, handler);

  void patch(String route, Function handler) => this.route('PATCH', route, handler);

  void update(String route, Function handler) => this.route('UPDATE', route, handler);
}
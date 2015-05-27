part of bridge.http;

abstract class Router {
  Set<Route> _routes;

  factory Router() => new _Router();

  void get(String route, Function handler);

  void post(String route, Function handler);

  void put(String route, Function handler);

  void update(String route, Function handler);

  void patch(String route, Function handler);

  void delete(String route, Function handler);
}

class _Router implements Router {
  Set<Route> _routes = new Set();

  void _route(String method, String route, Function handler) {
    _routes.add(new Route(method, route, handler));
  }

  void delete(String route, Function handler) => _route('DELETE', route, handler);

  void get(String route, Function handler) => _route('GET', route, handler);

  void patch(String route, Function handler) => _route('PATCH', route, handler);

  void post(String route, Function handler) => _route('POST', route, handler);

  void put(String route, Function handler) => _route('PUT', route, handler);

  void update(String route, Function handler) => _route('UPDATE', route, handler);
}

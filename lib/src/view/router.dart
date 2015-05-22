part of bridge.view;

abstract class Router {

  factory Router() => new _Router();

  void route(String method, String route, value);

  void get(String route, value);

  void post(String route, value);

  void patch(String route, value);

  void update(String route, value);

  void delete(String route, value);

  Route match(String method, String uri);
}

class _Router implements Router {

  final _routes = <Route>[];

  void route(String method, String route, value) {
    _routes.add(new Route(method, route, value));
  }

  Route match(String method, String uri) {
    for (var route in _routes)
      if (route.matches(method, uri)) return route;

    throw new InvalidArgumentException('[$uri] matches no routes.');
  }

  void get(String route, value) => this.route('GET', route, value);

  void post(String route, value) => this.route('POST', route, value);

  void delete(String route, value) => this.route('DELETE', route, value);

  void patch(String route, value) => this.route('PATCH', route, value);

  void update(String route, value) => this.route('UPDATE', route, value);

}
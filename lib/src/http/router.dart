part of bridge.http;

abstract class Router {
  Set<Route> _routes;

  factory Router() => new _Router();

  void get(String route, Function handler, {String name});

  void post(String route, Function handler, {String name});

  void put(String route, Function handler, {String name});

  void update(String route, Function handler, {String name});

  void patch(String route, Function handler, {String name});

  void delete(String route, Function handler, {String name});
}

class _Router implements Router {
  Set<Route> _routes = new Set();

  void _route(String method, String route, Function handler, String name) {
    _routes.add(new Route(method, route, handler, name: name));
  }

  void delete(String route,
              Function handler,
              {String name}) => _route('DELETE', route, handler, name);

  void get(String route,
           Function handler,
           {String name}) => _route('GET', route, handler, name);

  void patch(String route,
             Function handler,
             {String name}) => _route('PATCH', route, handler, name);

  void post(String route,
            Function handler,
            {String name}) => _route('POST', route, handler, name);

  void put(String route,
           Function handler,
           {String name}) => _route('PUT', route, handler, name);

  void update(String route,
              Function handler,
              {String name}) => _route('UPDATE', route, handler, name);
}

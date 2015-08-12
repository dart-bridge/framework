part of bridge.http;

abstract class Router {
  Set<Route> _routes;

  factory Router() => new _Router();

  void get(String route, Function handler, {String name, bool middleware});

  void post(String route, Function handler, {String name, bool middleware});

  void put(String route, Function handler, {String name, bool middleware});

  void update(String route, Function handler, {String name, bool middleware});

  void patch(String route, Function handler, {String name, bool middleware});

  void delete(String route, Function handler, {String name, bool middleware});

  void resource(String route, Object controller, {String name, bool middleware});
}

class _Router implements Router {
  Set<Route> _routes = new Set();

  void _route(String method, String route, Function handler, String name, bool middleware) {
    middleware = middleware == null ? true : middleware;
    _routes.add(new Route(method, route, handler, name: name, middleware: middleware));
  }

  void delete(String route,
              Function handler,
              {String name,
              bool middleware}) => _route('DELETE', route, handler, name, middleware);

  void get(String route,
           Function handler,
           {String name,
           bool middleware}) => _route('GET', route, handler, name, middleware);

  void patch(String route,
             Function handler,
             {String name,
             bool middleware}) => _route('PATCH', route, handler, name, middleware);

  void post(String route,
            Function handler,
            {String name,
            bool middleware}) => _route('POST', route, handler, name, middleware);

  void put(String route,
           Function handler,
           {String name,
           bool middleware}) => _route('PUT', route, handler, name, middleware);

  void update(String route,
              Function handler,
              {String name,
              bool middleware}) => _route('UPDATE', route, handler, name, middleware);

  void resource(String route,
                Object controller,
                {String name,
                bool middleware}) {
    var controllerMirror = reflect(controller);
    var baseName = name == null ? route.split('/').removeLast() : name;
    _restfulResource(route, controllerMirror, baseName, middleware);
  }

  void _restfulResource(String route, InstanceMirror controller, String name, bool middleware) {
    _route('GET', '$route', controller.getField(#index).reflectee, '$name.index', middleware);
    _route('GET', '$route/create', controller.getField(#create).reflectee, '$name.create', middleware);
    _route('POST', '$route', controller.getField(#store).reflectee, '$name.store', middleware);
    _route('GET', '$route/:id', controller.getField(#show).reflectee, '$name.show', middleware);
    _route('GET', '$route/:id/edit', controller.getField(#edit).reflectee, '$name.edit', middleware);
    _route('PUT', '$route/:id', controller.getField(#update).reflectee, '$name.update', middleware);
    _route('DELETE', '$route/:id', controller.getField(#destroy).reflectee, '$name.destroy', middleware);
  }
}

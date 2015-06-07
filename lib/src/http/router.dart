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

  void resource(String route, Object controller, {String name});
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

  void resource(String route, Object controller, {String name}) {
    var controllerMirror = reflect(controller);
    var baseName = name == null ? route.split('/').removeLast() : name;
    _restfulResource(route, controllerMirror, baseName);
  }

  void _restfulResource(String route, InstanceMirror controller, String name) {
    _route('GET', '$route', controller.getField(#index).reflectee, '$name.index');
    _route('GET', '$route/create', controller.getField(#create).reflectee, '$name.create');
    _route('POST', '$route', controller.getField(#store).reflectee, '$name.store');
    _route('GET', '$route/:id', controller.getField(#show).reflectee, '$name.show');
    _route('GET', '$route/:id/edit', controller.getField(#edit).reflectee, '$name.edit');
    _route('PUT', '$route/:id', controller.getField(#update).reflectee, '$name.update');
    _route('DELETE', '$route/:id', controller.getField(#destroy).reflectee, '$name.destroy');
  }
}

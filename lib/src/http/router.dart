part of bridge.http;

abstract class Router {
  Set<Route> _routes;

  factory Router() => new _Router();

  void get(String route,
           Function handler,
           {String name,
           bool middleware,
           List<Type> ignoreMiddleware});

  void post(String route,
            Function handler,
            {String name,
            bool middleware,
            List<Type> ignoreMiddleware});

  void put(String route,
           Function handler,
           {String name,
           bool middleware,
           List<Type> ignoreMiddleware});

  void update(String route,
              Function handler,
              {String name,
              bool middleware,
              List<Type> ignoreMiddleware});

  void patch(String route,
             Function handler,
             {String name,
             bool middleware,
             List<Type> ignoreMiddleware});

  void delete(String route,
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

  void _route(String method,
              String route,
              Function handler,
              String name,
              bool middleware,
              List<Type> ignoreMiddleware) {
    middleware = middleware == null ? true : middleware;
    ignoreMiddleware = ignoreMiddleware == null ? [] : ignoreMiddleware;
    _routes.add(new Route(
        method,
        route,
        handler,
        name: name,
        useMiddleware: middleware,
        ignoredMiddleware: ignoreMiddleware));
  }

  void delete(String route,
              Function handler,
              {String name,
              bool middleware, List<Type> ignoreMiddleware}) => _route('DELETE', route, handler, name, middleware, ignoreMiddleware);

  void get(String route,
           Function handler,
           {String name,
           bool middleware, List<Type> ignoreMiddleware}) => _route('GET', route, handler, name, middleware, ignoreMiddleware);

  void patch(String route,
             Function handler,
             {String name,
             bool middleware, List<Type> ignoreMiddleware}) => _route('PATCH', route, handler, name, middleware, ignoreMiddleware);

  void post(String route,
            Function handler,
            {String name,
            bool middleware, List<Type> ignoreMiddleware}) => _route('POST', route, handler, name, middleware, ignoreMiddleware);

  void put(String route,
           Function handler,
           {String name,
           bool middleware, List<Type> ignoreMiddleware}) => _route('PUT', route, handler, name, middleware, ignoreMiddleware);

  void update(String route,
              Function handler,
              {String name,
              bool middleware, List<Type> ignoreMiddleware}) => _route('UPDATE', route, handler, name, middleware, ignoreMiddleware);

  void resource(String route,
                Object controller,
                {String name,
                bool middleware, List<Type> ignoreMiddleware}) {
    var controllerMirror = reflect(controller);
    var baseName = name == null ? route.split('/').removeLast() : name;
    _restfulResource(route, controllerMirror, baseName, middleware, ignoreMiddleware);
  }

  void _restfulResource(String route, InstanceMirror controller, String name, bool middleware, List<Type> ignoreMiddleware) {
    _route('GET', '$route', controller.getField(#index).reflectee, '$name.index', middleware, ignoreMiddleware);
    _route('GET', '$route/create', controller.getField(#create).reflectee, '$name.create', middleware, ignoreMiddleware);
    _route('POST', '$route', controller.getField(#store).reflectee, '$name.store', middleware, ignoreMiddleware);
    _route('GET', '$route/:id', controller.getField(#show).reflectee, '$name.show', middleware, ignoreMiddleware);
    _route('GET', '$route/:id/edit', controller.getField(#edit).reflectee, '$name.edit', middleware, ignoreMiddleware);
    _route('PUT', '$route/:id', controller.getField(#update).reflectee, '$name.update', middleware, ignoreMiddleware);
    _route('DELETE', '$route/:id', controller.getField(#destroy).reflectee, '$name.destroy', middleware, ignoreMiddleware);
  }
}

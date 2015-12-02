library bridge.http.rest_router;

import 'dart:mirrors';

import '../../../http_shared.dart' as shared;

abstract class Router implements shared.Router {
  factory Router({String base: '',
  List<Type> ignoreMiddleware,
  List<Type> appendMiddleware}) =>
      new RestRouter(base, ignoreMiddleware ?? [], appendMiddleware ?? []);

  void resource(String route, Object controller);
}

class RestRouter extends shared.BaseRouter implements Router {
  RestRouter(String base, List<Type> ignoredMiddleware, List<Type> appendedMiddleware)
      : super(base, ignoredMiddleware, appendedMiddleware);

  void resource(String route, Object controller) {
    final controllerMirror = reflect(controller);
    final name = route.split('/').removeLast();
    _restfulResource(route, controllerMirror, name);
  }

  void _restfulResource(String route, InstanceMirror controller, String name) {
    if (controller.type.declarations.containsKey(#index))
      makeRoute('GET', '$route', controller
          .getField(#index)
          .reflectee, '$name.index');
    if (controller.type.declarations.containsKey(#create))
      makeRoute('GET', '$route/create', controller
          .getField(#create)
          .reflectee, '$name.create');
    if (controller.type.declarations.containsKey(#store))
      makeRoute('POST', '$route', controller
          .getField(#store)
          .reflectee, '$name.store');
    if (controller.type.declarations.containsKey(#show))
      makeRoute('GET', '$route/:id', controller
          .getField(#show)
          .reflectee, '$name.show');
    if (controller.type.declarations.containsKey(#edit))
      makeRoute('GET', '$route/:id/edit', controller
          .getField(#edit)
          .reflectee, '$name.edit');
    if (controller.type.declarations.containsKey(#update))
      makeRoute('PUT', '$route/:id', controller
          .getField(#update)
          .reflectee, '$name.update');
    if (controller.type.declarations.containsKey(#destroy))
      makeRoute('DELETE', '$route/:id', controller
          .getField(#destroy)
          .reflectee, '$name.destroy');
  }
}
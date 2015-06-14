part of bridge.http;

class UrlGenerator {
  final Router _router;
  final RegExp _wildcardMatcher = new RegExp(r':(\w+)');

  UrlGenerator(Router this._router);

  String url(String url) {
    return '/' + url.split('/').where((s) => s != '').join('/');
  }

  String route(String name, [Map<String, dynamic> wildcards]) {
    var route = _getNamedRoute(name);
    if (route == null)
      throw new InvalidArgumentException('No route named [$name] has been registered');
    return url(_replaceWildcards(route, wildcards));
  }

  Route _getNamedRoute(String name) {
    return _router._routes.firstWhere((r) => r.name == name, orElse: () => null);
  }

  String _replaceWildcards(Route route, Map<String, dynamic> wildcards) {
    return route.route.replaceAllMapped(_wildcardMatcher, (m) => wildcards.remove(m[1]));
  }
}

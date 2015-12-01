part of bridge.http.shared;

abstract class Router {
  RouteBuilder get(String url, Function handler);
}

abstract class RouteBuilder {
  RouteBuilder addMiddleware(middleware);
  RouteBuilder ignoreMiddleware(middleware);
}

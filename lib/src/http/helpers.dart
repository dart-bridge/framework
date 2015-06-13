part of bridge.http;

shelf.Response redirect(String url) {
  return new shelf.Response.found(url);
}

String url(String url) {
  return _urlGenerator.url(url);
}

String route(String name, [Map<String, dynamic> wildcards]) {
  return _urlGenerator.route(name, wildcards);
}
part of bridge.http;

shelf.Response redirect(String url) {
  return new shelf.Response.found(url);
}

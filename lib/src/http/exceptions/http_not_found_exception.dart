part of bridge.http;

class HttpNotFoundException implements Exception {
  final shelf.Request _request;

  HttpNotFoundException(this._request);

  String toString() => 'The route /${_request.url} was not found';
}

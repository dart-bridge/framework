part of bridge.http;

class TokenMismatchException implements Exception {
  final shelf.Request request;

  TokenMismatchException(this.request);

  String toString() =>
      'To make a ${request.method} request on '
          '/${request.url} a token must be provided on key [_token]';
}

part of bridge.http;

class HttpNotFoundException extends BaseException {
  shelf.Request request;

  HttpNotFoundException(shelf.Request request)
  : super('${request.method} ${request.url.path} was not found.') {
    this.request = request;
  }
}

part of bridge.view;

class HttpNotFoundException extends ViewException {

  HttpNotFoundException(Uri url) : super('[${url.path}] was not found! (404)');
}
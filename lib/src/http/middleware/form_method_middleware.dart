part of bridge.http;

class FormMethodMiddleware {
  shelf.Handler innerHandler;

  call(shelf.Handler innerHandler) {
    this.innerHandler = innerHandler;
    return _handleRequests;
  }

  _handleRequests(shelf.Request request) async {
    shelf.Response response = await innerHandler(request);

    return new shelf.Response(
        response.statusCode,
        body: _injectFormMethods(await response.readAsString()),
        headers: response.headers,
        context: response.context);
  }

  String _injectFormMethods(String body) {
    const pattern = r'''(<form[^>]*?method=)(['"])(put|patch|update|delete)\2([^>]*>)''';
    return body.replaceAllMapped(
        new RegExp(pattern, caseSensitive: false), (m) {
      return '${m[1]}${m[2]}POST${m[2]}${m[4]}'
          "<input type='hidden' name='_method' value='${m[3].toUpperCase()}'>";
    });
  }
}

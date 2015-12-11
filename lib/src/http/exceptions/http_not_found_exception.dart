part of bridge.http;

class HttpNotFoundException implements Exception {
  final shelf.Request _request;
  final File _file;

  HttpNotFoundException(this._request) : _file = null;

  HttpNotFoundException.file(this._file) : _request = null;

  String get resource {
    if (_request != null)
      return 'The route /${_request.url}';
    if (_file != null)
      return 'The file at ${path.relative(_file.path)}';
  }

  String toString() => '$resource was not found';
}

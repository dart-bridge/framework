part of bridge.view;

abstract class Router {

  factory Router(String path) => new _Router(path);

  void view(Pattern url, String viewPointer);

  void notFoundView(String viewPointer);

  final Match match;

  final String pointer;

  final bool is404;
}

class _Router implements Router {

  String _path;

  _Router(String this._path);

  Match _match;

  Match get match => _match;

  String _pointer;

  String get pointer => _pointer;

  String _matchedUrl;

  _attemptMatch(Pattern url, String pointer) {

    var matcher = new RegExp(r'^''$url'r'$');

    if (url == '(.*)' && _match != null) return;

    if (matcher.hasMatch(_path)) {
      _matchedUrl = url;
      _match = matcher.firstMatch(_path);
      _pointer = pointer;
    }
  }

  void view(Pattern url, String viewPointer) {

    _attemptMatch(url, viewPointer);
  }

  void notFoundView(String viewPointer) {

    view('(.*)', viewPointer);
  }

  bool get is404 => _matchedUrl == '(.*)';
}
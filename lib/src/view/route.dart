part of bridge.view;

class Route {

  final String method;
  final String route;
  final Function handler;

  const Route(String this.method, String this.route, Function this.handler);

  bool matches(String method, String uri) {
    if (_matchesMethod(method)) return false;
    return _matchesUri(uri);
  }

  bool _matchesMethod(String method) {
    return method != this.method;
  }

  bool _matchesUri(String uri) {
    return _segmentListsMatch(
        _getSegments(route),
        _getSegments(uri)
    );
  }

  Map<String, String> wildcards(String uri) {
    if (!_matchesUri(uri)) throw new RoutesDoNotMatchException(route, uri);
    return _wildcardsFrom(uri);
  }

  Map<String, String> _wildcardsFrom(String uri) {
    var sm = new Map.fromIterables(_getSegments(route), _getSegments(uri));
    return _filterSegmentsMapToWildcards(sm);
  }

  Map<String, String> _filterSegmentsMapToWildcards(Map<String, String> map) {
    new Map.from(map).forEach((key, value) {
      map.remove(key);
      if (_isWildcardName(key))
        _addWildcardToMap(key, value, map);
    });
    return map;
  }

  void _addWildcardToMap(wildcard, value, Map<String, String> map) {
    map[_getWildcardName(wildcard)] = value;
  }

  String _getWildcardName(String wildcard) {
    return wildcard.replaceFirst(':', '');
  }

  bool _segmentListsMatch(List<String> abstract, List<String> absolute) {
    if (_segmentListsDoNotHaveEqualLength(abstract, absolute)) return false;
    for (var i = 0; i < abstract.length; ++i)
      if (_segmentsDoNotMatch(abstract[i], absolute[i])) return false;

    return true;
  }

  bool _segmentListsDoNotHaveEqualLength(List<String> segments1, List<String> segments2) {
    return segments1.length != segments2.length;
  }

  bool _segmentsDoNotMatch(String abstract, String absolute) {
    if (_isWildcardName(abstract)) return false;
    if (abstract == absolute) return false;
    return true;
  }

  bool _isWildcardName(String abstract) {
    return abstract.startsWith(':');
  }

  List<String> _getSegments(String uri) {
    return _trimSlashes(uri).split('/');
  }

  String _trimSlashes(String input) {
    return input
    .replaceFirst(new RegExp(r'^/'), '')
    .replaceFirst(new RegExp(r'/$'), '');
  }
}

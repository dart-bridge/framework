part of bridge.http;

class Route {

  final String method;
  final String route;
  final Function handler;

  const Route(String this.method, String this.route, Function this.handler);

  bool matches(String method, String uri) {
    if (_doesntMatchMethod(method)) return false;
    return _matchesUri(uri);
  }

  bool _doesntMatchMethod(String method) {
    return method != this.method && _isntAHeadRequestInAGetRoute(method);
  }

  bool _isntAHeadRequestInAGetRoute(method) {
    return !(method == 'HEAD' && this.method == 'GET');
  }

  bool _matchesUri(String uri) {
    return _segmentListsMatch(
        _getSegments(route),
        _getSegments(uri)
    );
  }

  Map<String, String> wildcards(String uri) {
    if (!_matchesUri(uri)) return {};
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
    return _trimSlashes(uri).split('/')..removeWhere(_isEmpty);
  }

  bool _isEmpty(String s) => s.trim() == '';

  String _trimSlashes(String input) {
    return input
    .replaceFirst(new RegExp(r'^/'), '')
    .replaceFirst(new RegExp(r'/$'), '');
  }
}

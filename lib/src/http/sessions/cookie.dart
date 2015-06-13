part of bridge.http.sessions;

class Cookie {
  final String key;
  final String value;
  static const String sessionIdKey = 'X-BRIDGE-SESSION-ID';

  const Cookie(String this.key, String this.value);

  static List<Cookie> parse(String cookies) {
    return cookies.split(';').map(_parseCookie).toList();
  }

  static Cookie _parseCookie(String element) {
    var split = element.split('=');
    return new Cookie(split[0].trim(), split[1].trim());
  }

  String set({Duration duration,
             bool secure: false,
             bool httpOnly: false}) {
    return _setCookieParts(duration, secure, httpOnly).join('; ');
  }

  Iterable<String> _setCookieParts(Duration duration, bool secure, bool httpOnly) {
    var parts = <String>[
      '$key=$value',
      'Path=/',
    ];
    if (duration != null) parts.add('Max-Age=${duration.inSeconds}');
    if (secure) parts.add('Secure');
    if (httpOnly) parts.add('HttpOnly');
    return parts;
  }
}

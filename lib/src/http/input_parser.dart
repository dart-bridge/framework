part of bridge.http;

class InputParser {
  Formler _formler;
  final shelf.Request _request;
  List<int> _bytes;

  InputParser(shelf.Request this._request);

  Future<Input> parse() async {
    _formler = new Formler(await _getBytes(), _getBoundary());
    return new Input(_getBody());
  }

  Future<List<int>> _getBytes() async {
    List<List<int>> lines = await _request.read().toList();
    _bytes = lines.expand((l) => l).toList();
    return _bytes;
  }

  String _getBoundary() {
    try {
      return new RegExp(r'boundary=(-+[^ ]*)')
      .firstMatch(_request.headers['Content-Type'])[1]
      .replaceAll(new RegExp(r'^-*'), '')
      .replaceAll(new RegExp(r'-*$'), '');
    } catch (e) {
      return '';
    }
  }

  Object _getBody() {
    if (_request.headers['Content-Type'].contains('application/x-www-form-urlencoded'))
      return Formler.parseUrlEncoded(new String.fromCharCodes(_bytes));
    if (_request.headers['Content-Type'].contains('boundary'))
      return _formler.parse();
    try {
      return JSON.decode(new String.fromCharCodes(_bytes));
    } catch(e) {
      return new String.fromCharCodes(_bytes);
    }
  }
}

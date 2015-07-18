part of bridge.http;

class InputParser {
  final shelf.Request _request;
  Stream<List<int>> _bytes;
  MimeMultipartTransformer _transformer;
  String __bytesAsString;

  InputParser(shelf.Request this._request) {
    _transformer = new MimeMultipartTransformer(_getBoundary());
    _bytes = _request.read().asBroadcastStream();
  }

  Future<String> get _bytesAsString async {
    if (__bytesAsString == null)
      __bytesAsString = UTF8.decode((await _bytes.toList()).expand((l) => l).toList());
    return __bytesAsString;
  }

  Future<Input> parse() async {
    var body = await _getBody();
    return new Input(body);
  }

  String _getBoundary() {
    try {
      return new RegExp(r'boundary=(-+[^ ]*)')
      .firstMatch(_request.headers['Content-Type'])[1]/*
      .replaceAll(new RegExp(r'^-*'), '')
      .replaceAll(new RegExp(r'-*$'), '')*/;
    } catch (e) {
      return '';
    }
  }

  Future<Object> _getBody() async {
    if (_request.headers['Content-Type'].contains('application/x-www-form-urlencoded'))
      return Formler.parseUrlEncoded(await _bytesAsString);
    if (_request.headers['Content-Type'].contains('boundary'))
      return _multiPart(_transformMultipartData());
    try {
      return JSON.decode(await _bytesAsString);
    } catch(e) {
      return {'data': await _bytesAsString};
    }
  }

  Stream<http_server.HttpMultipartFormData> _transformMultipartData() {
    return _bytes.transform(_transformer).map(http_server.HttpMultipartFormData.parse);
  }

  Future<Object> _multiPart(Stream<http_server.HttpMultipartFormData> data) async {
    List<http_server.HttpMultipartFormData> datas = await data.toList();
    return new Map<String, dynamic>.fromIterables(_namesOf(datas), await _valuesOf(datas));
  }

  Iterable<String> _namesOf(List<http_server.HttpMultipartFormData> datas) sync* {
    for (var data in datas) {
      if (data.contentDisposition.parameters.containsKey('name'))
        yield data.contentDisposition.parameters['name'];
      else if (data.contentDisposition.parameters.containsKey('filename'))
        yield data.contentDisposition.parameters['filename'];
      else yield new DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<Iterable> _valuesOf(List<http_server.HttpMultipartFormData> datas) {
    return Future.wait(datas.map((data) => (data.isText) ? _asString(data) : _asFile(data)));
  }

  Future<String> _asString(Stream<String> data) async {
    return (await data.toList()).join('\n');
  }

  Future<UploadedFile> _asFile(http_server.HttpMultipartFormData data) async {
    return new UploadedFile(data);
  }
}

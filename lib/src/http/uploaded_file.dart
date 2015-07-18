part of bridge.http;

class UploadedFile implements Serializable {
  http_server.HttpMultipartFormData _data;

  UploadedFile(http_server.HttpMultipartFormData this._data);

  Future<File> saveTo(String path) async {
    var file = new File(path);
    await file.openWrite().addStream(_data);
    return file;
  }

  ContentType get contentType => _data.contentType;

  String get name => _data.contentDisposition.parameters['filename'];

  Object serialize() => {
    'name': name,
    'contentType': contentType.toString(),
  };
}

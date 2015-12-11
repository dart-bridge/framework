part of bridge.http;

HttpConfig _helperConfig;
UrlGenerator _helperUrlGenerator;

shelf.Response redirect(String url) {
  return new shelf.Response.found(url);
}

String url(String url) {
  return _helperUrlGenerator.url(url);
}

String route(String name, [Map<String, dynamic> wildcards]) {
  return _helperUrlGenerator.route(name, wildcards);
}

Future<shelf.Response> public(String filepath) async {
  final dir = Environment.isDevelopment
      ? new Directory(_helperConfig.publicRoot)
      : new Directory(path.join(
      _helperConfig.buildRoot,
      _helperConfig.publicRoot));
  final file = new File(path.join(dir.path, filepath));
  if (!await file.exists())
    throw new HttpNotFoundException.file(file);
  return new shelf.Response.ok(file.openRead(), headers: {
    'Content-Type': ContentType.HTML.toString()
  });
}
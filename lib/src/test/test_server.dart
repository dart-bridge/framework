part of bridge.test;

class TestServer {
  final Container _container;
  final http.Pipeline _pipeline;

  TestServer(this._container, this._pipeline);

  TestRequest request(http.Request request) {
    return new TestRequest(_pipeline.handle(request, _container));
  }

  http.Request _request(
      String method,
      String path,
      Map<String, dynamic> data
      ) {
    if (method.toUpperCase() == 'GET')
      return new http.Request(method,
          new Uri.http('localhost', path, data));

    return new http.Request(method,
        new Uri.http('localhost', path), body: JSON.encode(data));
  }

  TestRequest get(String route, [Map<String, String> data = const {}]) {
    return request(_request('GET', route, data));
  }

  TestRequest post(String route, [data]) {
    return request(_request('POST', route, data));
  }

  TestRequest put(String route, [data]) {
    return request(_request('PUT', route, data));
  }

  TestRequest update(String route, [data]) {
    return request(_request('UPDATE', route, data));
  }

  TestRequest patch(String route, [data]) {
    return request(_request('PATCH', route, data));
  }

  TestRequest delete(String route, [data]) {
    return request(_request('DELETE', route, data));
  }
}

class TestRequest implements Future<http.Response> {
  final Future<http.Response> _future;

  TestRequest(this._future);

  Future<String> get body => then((r) => r.readAsString());

  Future<http.Response> get response => this;

  Future<Map<String, String>> get headers => then((r) => r.headers);

  @override
  Stream<http.Response> asStream() {
    return _future.asStream();
  }

  @override
  Future catchError(Function onError, {bool test(Object error)}) {
    return _future.catchError(onError, test: test);
  }

  @override
  Future then(onValue(http.Response value), {Function onError}) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Future timeout(Duration timeLimit, {onTimeout()}) {
    return _future.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<http.Response> whenComplete(action()) {
    return _future.whenComplete(action);
  }
}

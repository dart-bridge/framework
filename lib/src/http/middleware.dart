part of bridge.http;

abstract class Middleware {
  Container _container;
  _ResponseMapper _responseMapper;

  shelf.Middleware transform(Container container) {
    _container = container;
    _responseMapper = container.make(_ResponseMapper);

    return (shelf.Handler innerHandler) {
      return (shelf.Request request) async {
        var handledRequest = await _request(request);
        if (handledRequest is shelf.Response) return handledRequest;

        var response;

        if (handledRequest is shelf.Request) response = await innerHandler(handledRequest);
        else response = await innerHandler(request);

        return _response(response);
      };
    };
  }

  Future<shelf.Message> _request(shelf.Request request) async {
    if (!_container.hasMethod(this, 'request')) return null;

    var returnValue = await _container.resolveMethod(
        this,
        'request',
        injecting: {
          shelf.Request: request
        });

    if (returnValue == null) return null;
    if (returnValue is shelf.Request) return returnValue;
    return _responseMapper.valueToResponse(returnValue);
  }

  Future<shelf.Response> _response(shelf.Response response) async {
    if (!_container.hasMethod(this, 'response')) return response;


    var returnValue = await _container.resolveMethod(
        this,
        'response',
        injecting: {
          shelf.Response: response
        });

    if (returnValue == null) return response;
    if (returnValue is shelf.Response) return returnValue;
    return _responseMapper.valueToResponse(returnValue);
  }
}

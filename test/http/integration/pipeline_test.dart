import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';
import 'package:shelf/src/message.dart';
import 'dart:convert';
import 'dart:async';

class PipelineTest extends Pipeline implements TestCase {
  setUp() {}

  tearDown() {}

  @override get middleware => [
    functionMiddleware,
    ClassMiddleware,
    BridgeMiddleware,
  ];

  @override get errorHandlers => {
    CsrfException: csrfErrorHandler,
  };

  @override routes(Router router) {
    final handler = () => 'response';

    router.get('/', handler);

    router.get('/add', handler)
        .withMiddleware(extraMiddleware);

    router.get('/ignore', handler)
        .ignoreMiddleware(ClassMiddleware);

    router.get('/add-ignore', handler)
        .withMiddleware(extraMiddleware)
        .ignoreMiddleware(functionMiddleware);

    router.get('/di', (Dependency dependency, Request request) {
      return '${dependency.property}/${request.url}';
    });

    router.get('/input', (Input input) {
      return input;
    }).withMiddleware(InputMiddleware);

    router.get('/csrf', (Input input) {
      return input['payload'];
    }).withMiddleware(InputMiddleware)
        .withMiddleware(CsrfMiddleware);
  }

  @test
  it_creates_an_http_pipeline() async {
    expect(await _get('/'), '(((response)function)class)bridge');
  }

  @test
  it_lets_the_router_add_and_remove_middleware() async {
    // ( ( ( ( /add ) functionMiddleware ) ClassMiddleware ) BridgeMiddleware ) extraMiddleware
    expect(await _get('/add'), '((((response)function)class)bridge)extra');

    // ( ( /ignore ) functionMiddleware ) BridgeMiddleware
    expect(await _get('/ignore'), '((response)function)bridge');

    // ( ( ( handler ) ClassMiddleware ) BridgeMiddleware ) extraMiddleware
    expect(await _get('/add-ignore'), '(((response)class)bridge)extra');
  }

  @test
  it_supports_dependency_injection_in_handlers() async {
    // ( ( ( /di ) functionMiddleware ) ClassMiddleware ) BridgeMiddleware
    expect(await _get('/di'), '(((bridge/di)function)class)bridge');
  }

  @test
  it_has_a_middleware_for_getting_the_request_input() async {
    expect(await _get('/input', {'key': 'value'}),
        '((({"key":"value"})function)class)bridge');
  }

  @test
  it_has_a_middleware_to_protect_from_csrf() async {
    expect(await _post('/csrf'),
        '(((caught csrf error)function)class)bridge');
    expect(await _post('/csrf', {'_token': 'x', 'payload': 'y'}),
        '(((y)function)class)bridge');
  }

  String csrfErrorHandler(CsrfException exception, StackTrace stack) {
    return 'caught csrf error';
  }

  Future<String> _get(String path, [Map<String, String> parameters]) {
    return _make(_request(path, parameters: parameters));
  }

  Future<String> _post(String path, [Map<String, String> parameters]) {
    return _make(_request(path, parameters: parameters, method: 'POST'));
  }

  Future<String> _make(Request request) {
    return make(request).then(_read);
  }

  Request _request(String path, {
  String method: 'GET',
  Map<String, String> parameters
  }) {
    return new Request(method, new Uri.http('example.com', path, parameters));
  }
}

Future<String> _read(Message message) {
  return message.read().map(UTF8.decode).join('\r\n');
}

Handler _wrapResponse(String appendix, Handler inner) {
  return (Request request) async {
    final Response response = await inner(request);
    final body = await _read(response);
    return response.change(
        body: '($body)$appendix'
    );
  };
}

Handler functionMiddleware(Handler inner) {
  return _wrapResponse('function', inner);
}

class ClassMiddleware {
  Handler call(Handler inner) {
    return _wrapResponse('class', inner);
  }
}

Handler extraMiddleware(Handler inner) {
  return _wrapResponse('extra', inner);
}

class BridgeMiddleware extends Middleware {
  final Dependency _dependency;

  BridgeMiddleware(this._dependency);

  Future<Response> handle(Request request) async {
    final response = await super.handle(request);
    final body = await _read(response);
    return response.change(
        body: '($body)${_dependency.property}'
    );
  }
}

class Dependency {
  final property = 'bridge';
}

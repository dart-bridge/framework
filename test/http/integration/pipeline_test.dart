import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'package:bridge/http.dart';
import 'package:shelf/src/message.dart';
import 'dart:convert';
import 'dart:async';

class PipelineTest extends Pipeline implements TestCase {
  PipelineTest() : super(new Router(), new Container());

  setUp() {}

  tearDown() {}

  @override get middleware => [
    BridgeMiddleware,
    ClassMiddleware,
    functionMiddleware,
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

    router.post('/csrf', (Input input) {
      // TODO: Implement Sessions and CSRF protection
      if(input['_token'] != 'x') throw new CsrfException();
      return input['payload'];
    }).withMiddleware(InputMiddleware)
        .withMiddleware(CsrfMiddleware);
  }

  @test
  it_creates_an_http_pipeline() async {
    expect(await _get('/'), 'bridge(class(function(response)))');
  }

  @test
  it_lets_the_router_add_and_remove_middleware() async {
    // BridgeMiddleware ( ClassMiddleware ( functionMiddleware ( extraMiddleware ( /add ) ) ) )
    expect(await _get('/add'), 'bridge(class(function(extra(response))))');

    // BridgeMiddleware ( functionMiddleware ( /ignore ) )
    expect(await _get('/ignore'), 'bridge(function(response))');

    // BridgeMiddleware ( ClassMiddleware ( extraMiddleware ( handler ) ) )
    expect(await _get('/add-ignore'), 'bridge(class(extra(response)))');
  }

  @test
  it_supports_dependency_injection_in_handlers() async {
    // BridgeMiddleware ( ClassMiddleware ( functionMiddleware ( /di ) ) )
    expect(await _get('/di'), 'bridge(class(function(bridge/di)))');
  }

  @test
  it_has_a_middleware_for_getting_the_request_input() async {
    expect(await _get('/input', {'key': 'value'}),
        'bridge(class(function({"key":"value"})))');
  }

  @test
  it_has_a_middleware_to_protect_from_csrf() async {
    expect(await _post('/csrf'),
        'caught csrf error');
    expect(await _post('/csrf', {'_token': 'x', 'payload': 'y'}),
        'bridge(class(function(y)))');
  }

  String csrfErrorHandler(CsrfException exception, StackTrace stack) {
    return 'caught csrf error';
  }

  Future<String> _get(String path, [Map<String, String> parameters]) {
    return _handle(_request(path, parameters: parameters));
  }

  Future<String> _post(String path, [Map<String, String> parameters]) {
    return _handle(_request(path, parameters: parameters, method: 'POST'));
  }

  Future<String> _handle(Request request) {
    return handle(request).then(_read);
  }

  Request _request(String path, {
  String method: 'GET',
  Map<String, String> parameters
  }) {
    final uri = method == 'GET'
        ? new Uri.http('example.com', path, parameters)
        : new Uri.http('example.com', path);
    final body = method == 'GET' ? null : JSON.encode(parameters ?? {});
    return new Request(method, uri, body: body);
  }
}

Future<String> _read(Message message) {
  return message.read().map(UTF8.decode).join('\r\n');
}

Handler _wrapResponse(String wrapName, Handler inner) {
  return (Request request) async {
    final Response response = await inner(request);
    final body = await _read(response);
    return response.change(
        body: '$wrapName($body)'
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
        body: '${_dependency.property}($body)'
    );
  }
}

class Dependency {
  final property = 'bridge';
}

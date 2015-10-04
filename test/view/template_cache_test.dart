import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';
export '_external.dart';

class TemplateCacheTest implements TestCase {
  setUp() {}

  tearDown() {}

  Future _expectGenerates(String template,
      List<String> expectedLines,
      {Map<Symbol, dynamic> variables: const {}}) async {
    final cache = new ExampleTemplateCache(variables);
    expect(await cache.$generate(template).toList(), expectedLines);
  }

  @test
  it_contains_templates() async {
    _expectGenerates('degenerate', []);
  }

  @test
  it_returns_the_templates_as_streams_of_lines() async {
    _expectGenerates('simple', [
      'a',
      'b',
      'c',
    ]);
  }

  @test
  it_dynamically_uses_variables() async {
    _expectGenerates('variable', ['xyz'], variables: {#variable: 'y'});
  }

  @test
  it_defaults_to_null() async {
    _expectGenerates('missingVariable', ['ab']);
  }

  @test
  it_dynamically_resolves_external_code() async {
    _expectGenerates('resolve', [
      'function',
      'staticGetter',
      'staticMethod',
      'getter',
      'method',
    ]);
  }

  @test
  it_has_conditionals() async {
    _expectGenerates('conditionals', [
      'shown',
      'shown',
      'shown',
    ]);
  }

  @test
  it_escapes_variables() async {
    _expectGenerates('variable',
        ['x&lt;br&gt;z'],
        variables: {#variable: '<br>'});
  }

  @test
  it_has_for_in_loops() async {
    _expectGenerates('forInLoop',
        ['1', '2', '3'],
        variables: {#variables: [1, 2, 3]});
  }

  @test
  it_has_inheritance() async {
    _expectGenerates('child', [
      'before',
      'inside',
      'after',
    ]);
  }

  @test
  it_can_still_use_parents_without_inheritance() async {
    _expectGenerates('parent', [
      'before',
      'after',
    ]);
  }

  @test
  it_can_nest_extends() async {
    _expectGenerates('nestedChild', [
      'before',
      'before inner',
      'inside',
      'after inner',
      'after',
    ]);
  }

  @test
  it_can_include_partials() async {
    _expectGenerates('partial', ['xyz'], variables: {#variable: 'y'});
  }
}

class ExampleTemplateCache extends TemplateCache {
  ExampleTemplateCache(Map<Symbol, dynamic> variables) : super(variables);

  Map<String, TemplateGenerator> get collection => {
    'degenerate': () async* {},
    'simple': () async* {
      yield '''a''';                                               // a
      yield '''b''';                                               // b
      yield '''c''';                                               // c
    },
    'variable': () async* {
      yield '''x${$esc(variable)}z''';                             // x${variable}z
    },
    'missingVariable': () async* {
      yield '''a${$esc(variableThatDoesNotExist)}b''';             // a${variableThatDoesNotExist}b
    },
    'resolve': () async* {
      yield '''${$esc(function())}''';                             // ${function()}
      yield '''${$esc(ExternalClass.staticGetter)}''';             // ${ExternalClass.staticGetter}
      yield '''${$esc(ExternalClass.staticMethod())}''';           // ${ExternalClass.staticMethod()}
      yield '''${$esc($new(#ExternalClass, [], {}).getter)}''';    // ${new ExternalClass().getter}
      yield '''${$esc($new(#ExternalClass, [], {}).method())}''';  // ${new ExternalClass().method()}
    },
    'conditionals': () async* {
      yield* $if([[true, () async* {                               // @if (true)
        yield '''shown''';                                         //   shown
      }], [() async* {                                             // @else
        yield '''not shown''';                                     //   not shown
      }]]);                                                        // @end if

      yield* $if([[false, () async* {                              // @if (false)
        yield '''not shown''';                                     //   not shown
      }], [true, () async* {                                       // @else if (true)
        yield '''shown''';                                         //   shown
      }]]);                                                        // @end if

      yield* $if([[false, () async* {                              // @if (false)
        yield '''not shown''';                                     //   not shown
      }], [false, () async* {                                      // @else if (false)
        yield '''not shown''';                                     //   not shown
      }], [() async* {                                             // @else
        yield '''shown''';                                         //   shown
      }]]);                                                        // @end if
    },
    'forInLoop': () async* {
      yield* $for(variables, (variable) async* {                   // @for (variable in variables)
        yield '${$esc('$variable')}';                              //   $variable
      });                                                          // @end for
    },
    'parent': () async* {
      yield '''before''';                                          // before
      yield* $block('block');                                      // @block ('block')
      yield '''after''';                                           // after
    },
    'child': () async* {
      yield* $extends('parent', {                                  // @extends ('parent')
        'block': () async* {                                       // @block ('block')
          yield '''inside''';                                      //   inside
        },                                                         // @end block
      });
    },
    'nestingParent': () async* {
      yield* $extends('parent', {                                  // @extends ('parent')
        'block': () async* {                                       // @block ('block')
          yield '''before inner''';                                //   before inner
          yield* $block('innerBlock');                             //   @block ('innerBlock')
          yield '''after inner''';                                 //   after inner
        },                                                         // @end block
      });
    },
    'nestedChild': () async* {
      yield* $extends('nestingParent', {                           // @extends ('nestingParent')
        'innerBlock': () async* {                                  // @block ('innerBlock')
          yield '''inside''';                                      //   inside
        },                                                         // @end block
      });
    },
    'partial': () async* {
      yield* $generate('variable');                                // @include ('variable')
    },
  };
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';
import 'dart:io';
import 'dart:async';

class InputTest implements TestCase {
  setUp() {}

  tearDown() {}

  @test
  it_extends_a_map() {
    const content = const {'key': 'value'};
    final input = new Input(content);
    expect(input, new isInstanceOf<Map>());
    expect(input.toMap(), equals(content));
  }

  @test
  it_is_immutable() {
    final input = new Input({'key': 'value'});
    expect(input['key'], equals('value'));
    expect(() => input['key'] = 'new value', throws);
  }

  @test
  it_has_a_get_helper() {
    final input = new Input({'key':'value'});
    expect(input.get('key'), equals('value'));
    expect(input.get('key', 'default'), equals('value'));
    expect(input.get('non_key', 'default'), equals('default'));
  }

  @test
  it_has_an_alias_for_checking_if_a_key_exists() {
    final input = new Input({'key': 'value'});
    expect(input.has('key'), isTrue);
    expect(input.has('non_key'), isFalse);
  }

  @test
  it_creates_a_copy_of_the_internal_map() {
    final input = new Input({'key': 'value'});
    input.toMap()['key'] = 'new value';
    expect(input['key'], equals('value'));
  }

  @test
  it_can_be_filtered_to_only_contain_uploaded_files() {
    final fileA = new DummyUploadedFile();
    final fileB = new DummyUploadedFile();

    final input = new Input({
      'key': 'value',
      'file_a': fileA,
      'file_b': fileB
    });

    expect(input.files.toMap(), equals({
      'file_a': fileA,
      'file_b': fileB
    }));
  }

  @test
  it_can_get_a_map_of_only_the_specified_keys() {
    final input = new Input({
      'a': 'x',
      'b': 'y',
      'c': 'z',
    });

    expect(input.only(['a', 'c']).toMap(), equals({
      'a': 'x',
      'c': 'z',
    }));
  }
}

class DummyUploadedFile implements UploadedFile {
  ContentType get contentType => null;

  String get name => null;

  Future<File> saveTo(String path) async => new File('.');
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'dart:io';

class ConfigTest implements TestCase {

  Config config;

  setUp() async {
    config = await Config.load(new Directory('test/core/config_example'));
  }

  tearDown() {}

  @test
  it_throws_when_the_directory_does_not_exist() {
    expect(Config.load(new Directory('path/does/not/exist')), throwsA(const isInstanceOf<ConfigException>()));
  }

  @test
  it_contains_a_map() {
    expect(config['config'], equals({'key':'value'}));
  }

  @test
  it_can_pick_a_value_from_a_dot_path() {
    expect(config['config.key'], equals('value'));
  }

  @test
  it_can_replace_a_value_with_dot_path() {
    config['config.key'] = 'newValue';
    expect(config['config.key'], equals('newValue'));
  }

  @test
  it_can_create_a_new_nested_key_with_value() {
    config['config.newKey'] = 'newValue';
    expect(config['config.newKey'], equals('newValue'));
  }

  @test
  it_can_contain_a_list() {
    config['config.list'] = ['more', 'values'];
    expect(config['config.list'], equals(['more', 'values']));
  }

  @test
  it_can_access_nested_lists_by_index_in_dot_path() {
    config['config.list'] = [
      [
        'nested',
        'list',
      ]
    ];
    expect(config['config.list.0.0'], equals('nested'));
  }

  @test
  it_can_look_for_a_value_and_provide_a_default_if_key_does_not_exist() {
    expect(config('config.key', 'default'), equals('value'));
    expect(config('config.doesNotExist', 'default'), equals('default'));
  }
}
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether.dart';
import 'dart:convert';

class SerializationManagerTest implements TestCase {
  SerializationManager manager;

  setUp() {
    manager = new SerializationManager();
    manager.registerStructure(
        'ExampleSerializable',
        ExampleSerializable,
            (s) => new ExampleSerializable.deserialize(s));
  }

  tearDown() {
  }

  Object _serializeAndDeserialize(Object object) {
    return manager.deserialize(JSON.decode(JSON.encode(manager.serialize(object))));
  }

  expectSerializes(Object object) {
    expect(_serializeAndDeserialize(object), equals(object));
  }

  expectSerializesTo(Object object, Matcher matcher) {
    expect(_serializeAndDeserialize(object), matcher);
  }

  @test
  it_does_nothing_when_serializing_primitives() async {
    expectSerializes(null);
    expectSerializes(1);
    expectSerializes(1.0);
    expectSerializes('string');
  }

  @test
  it_allows_for_lists_and_maps() async {
    expectSerializes([]);
    expectSerializes({});
  }

  @test
  it_allows_for_lists_and_maps_with_primitives() async {
    expectSerializes([null, 'string']);
    expectSerializes({'firstKey': 'value', 'secondKey': null});
  }

  @test
  it_serializes_serializable_types() async {
    expectSerializesTo(new ExampleSerializable(), const isInstanceOf<ExampleSerializable>());
  }

  @test
  it_serializes_lists_and_maps_with_registered_structures_as_values() async {
    expectSerializesTo([
      new ExampleSerializable(),
      new ExampleSerializable(),
      {
        'key': new ExampleSerializable(),
      }
    ], predicate((v) {
      return v[0].prop == 'value'
      && v[1].prop == 'value'
      && v[2]['key'].prop == 'value';
    }));
  }

  @test
  it_casts_unregistered_classes_to_json_if_possible_otherwise_string() async {
    expect(manager.serialize(new UnregisteredSerializable()),
    equals({'key': 'value'}));
    expect(manager.serialize(new ExampleUnserializableWithToJsonMethod()),
    equals({'key': 'value'}));
    expect(manager.serialize(new ExampleUnserializable()),
    equals('Instance of \'ExampleUnserializable\''));
  }
}

class UnregisteredSerializable implements Serializable {
  Object serialize() => {'key': 'value'};
}

class ExampleUnserializableWithToJsonMethod {
  toJson() => {'key': 'value'};
}

class ExampleUnserializable {
}

class ExampleSerializable implements Serializable {
  String prop = 'value';

  ExampleSerializable();

  ExampleSerializable.deserialize(serialized) {
    prop = serialized['prop'];
  }

  Object serialize() => {'prop': prop};
}
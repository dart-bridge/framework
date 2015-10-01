import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/transport.dart';

class SerializerTest implements TestCase {
  Serializer serializer;

  setUp() {
    serializer = new Serializer();
  }

  tearDown() {}

  void _expectSerializes(Object object, Object serialized) {
    expect(serializer.serialize(object), equals(serialized));
  }

  void _expectDeserializes(Object object, Object deserialized) {
    expect(serializer.deserialize(object), equals(deserialized));
  }

  void _expectTransforms(Object object) {
    expect(
        serializer.deserialize(serializer.serialize(object)),
        equals(object));
  }

  void _registerDataStructure() {
    serializer.register(
        'DataStructure',
        DataStructure,
        serialize: (DataStructure o) {
          return [o.string, o.integer];
        },
        deserialize: (List o) {
          return new DataStructure(o[0], o[1]);
        });

    serializer.register(
        'NestingDataStructure',
        NestingDataStructure,
        serialize: (NestingDataStructure o) {
          return [o.float, o.first, o.second];
        },
        deserialize: (List o) {
          return new NestingDataStructure(o[0], o[1], o[2]);
        });
  }

  @test
  it_doesnt_serialize_primitives() {
    _expectSerializes(null, null);
    _expectSerializes('x', 'x');
    _expectSerializes(0, 0);
    _expectSerializes(1.2, 1.2);
    _expectSerializes(true, true);
  }

  @test
  it_casts_unregistered_classes_to_string() {
    _expectSerializes(const DataStructure('x', 0), "Instance of 'DataStructure'");
  }

  @test
  it_preserves_lists_and_maps() {
    _expectSerializes(
        [0, 1, const DataStructure('', 0)],
        [0, 1, "Instance of 'DataStructure'"]);
    _expectSerializes(
        {'x': 1, 'y': const DataStructure('', 0)},
        {'x': 1, 'y': "Instance of 'DataStructure'"});
  }

  @test
  it_can_register_a_serializer() {
    _registerDataStructure();
    _expectSerializes(const DataStructure('x', 0), {
      r'$$': 'DataStructure',
      r'$$$': ['x', 0]
    });
  }

  @test
  it_combines_the_serializers_with_primitives() {
    _registerDataStructure();
    _expectSerializes([0, {'x': const DataStructure('x', 0)}], [
      0,
      {
        'x': {
          r'$$': 'DataStructure',
          r'$$$': ['x', 0]
        }
      }
    ]);
  }

  @test
  it_doesnt_deserialize_primitives() {
    _expectDeserializes(null, null);
    _expectDeserializes('x', 'x');
    _expectDeserializes(0, 0);
    _expectDeserializes(1.2, 1.2);
    _expectDeserializes(true, true);
  }

  @test
  it_can_register_deserializer() {
    _registerDataStructure();
    _expectDeserializes({
      r'$$': 'DataStructure',
      r'$$$': ['x', 0]
    }, const DataStructure('x', 0));
  }

  @test
  it_can_serialize_nested_data_structures() {
    _registerDataStructure();
    _expectSerializes(
        const NestingDataStructure(.1,
            const DataStructure('x', 0),
            const DataStructure('y', 1)), {
      r'$$': 'NestingDataStructure',
      r'$$$': [
        .1,
        { r'$$': 'DataStructure', r'$$$': ['x', 0] },
        { r'$$': 'DataStructure', r'$$$': ['y', 1] },
      ]
    });
  }

  @test
  integration() {
    _registerDataStructure();
    _expectTransforms({
      'a': [0, 1.2],
      'b': {'x': true},
      'c': [{
        'y': const DataStructure('z1', 10),
        'z': const NestingDataStructure(.2,
            const DataStructure('z2', 20),
            const DataStructure('z3', 30)),
      }]
    });
  }
}

class DataStructure {
  final String string;
  final int integer;

  const DataStructure(String this.string, int this.integer);

  bool operator ==(DataStructure other) {
    return other.integer == integer && other.string == string;
  }
}

class NestingDataStructure {
  final double float;
  final DataStructure first;
  final DataStructure second;

  const NestingDataStructure(double this.float,
      DataStructure this.first, DataStructure this.second);

  bool operator ==(NestingDataStructure other) {
    return other.float == float
        && other.first == first
        && other.second == second;
  }
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'package:bridge/database.dart';
import 'dart:async';

class RepositoryTest implements TestCase {
  Repository<TestModel> repository;
  MockDatabase database;
  MockCollection collection;

  setUp() {
    collection = new MockCollection();
    database = new MockDatabase(collection);
    repository = new Repository<TestModel>(new Application(), database);
  }

  tearDown() {}

  @test
  it_gets_all_in_collection() async {
    collection.allFields = [
      {'id': 1, 'stringField': 'string', 'intField': 1},
      {'id': 1, 'stringField': 'string', 'intField': 1},
    ];

    var all = await repository.all();

    expect(all.length, equals(2));
    expect(all[0], const isInstanceOf<TestModel>());
    expect(all[0].stringField, equals('string'));
    expect(all[0].intField, equals(1));
  }

  @test
  it_finds_a_model_from_id() async {
    collection.allFields = [
      {'id': 1, 'stringField': 'string', 'intField': 1}
    ];
    var model = await repository.find(1);
    expect(model, const isInstanceOf<TestModel>());
    expect(model.stringField, equals('string'));
    expect(model.intField, equals(1));
  }

  @test
  it_saves_data() async {
    var wasCalled = false;
    collection.onSave = (data) {
      wasCalled = true;
      expect(data, containsPair('id', null));
      expect(data, containsPair('stringField', 'title'));
      expect(data, containsPair('intField', 1));
      expect(data['createdAt'], new isInstanceOf<DateTime>());
      expect(data['updatedAt'], new isInstanceOf<DateTime>());
    };
    
    await repository.save(
        new TestModel()
          ..stringField = 'title'
          ..intField = 1);
    
    expect(wasCalled, isTrue);
  }
}

class TestModel extends Model {
  @field String stringField;
  @field int intField;
  String normalProperty;
}

class MockDatabase implements Database {
  Collection _collection;

  MockDatabase(this._collection);

  Collection collection(String name) {
    return _collection;
  }

  Future connect(Config config) async {
  }

  Future close() async {
  }
}

class MockCollection implements Collection {
  List<Map> allFields;

  Future<List<Map>> all() async {
    return allFields;
  }

  Future<Map> find(id) async {
    return allFields[0];
  }
  
  Function onSave;
  
  Future save(data) => onSave(data);

  noSuchMethod(Invocation invocation) {

  }
}
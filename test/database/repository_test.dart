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
}

class TestModel {
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

  noSuchMethod(Invocation invocation) {

  }
}
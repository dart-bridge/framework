import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/database.dart';

class InMemoryDatabaseTest implements TestCase {
  InMemoryDatabase database;

  setUp() {
    database = new InMemoryDatabase();
  }

  tearDown() {}

  @test
  it_can_store_items_in_collections() async {
    await database.collection('test').save({'key': 'value'});
    expect(await database.collection('test').where('key', isEqualTo: 'value').first(), equals({'key': 'value'}));
  }
}

import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/tether_shared.dart';
import 'dart:isolate';

class IsolateTetherTest implements TestCase {
  Tether tether;

  setUp() async {
    registerTetherTransport();
    tether = await IsolateTether.spawn(client);
  }

  tearDown() {}

  @test
  it_can_communicate() async {
    final response = await tether.send('x', 'y');
    expect(response, 'z');
  }
}

client(SendPort port) async {
  registerTetherTransport();
  final Tether tether = await IsolateTether.client(port);

  tether.listen('x', (String y) {
    if (y != 'y') throw '';
    return 'z';
  });
}

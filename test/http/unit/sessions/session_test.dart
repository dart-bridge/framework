import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/http.dart';

class SessionTest implements TestCase {
  Session session;

  setUp() {
    session = new Session('id');
  }

  tearDown() {}

  @test
  it_keeps_track_of_a_map() {
    session.set('key', 'value');
    expect(session['key'], equals('value'));
  }

  @test
  it_keeps_separate_track_of_flashed_variables() {
    session.flash('key', 'value');
    expect(session['key'], equals('value'));
    session.clearOldFlashes();
    session.clearOldFlashes();
    expect(session['key'], equals(null));
  }

  @test
  it_can_reflash_a_flashed_variable_and_prevent_it_from_being_cleared_once() {
    session.flash('key', 'value');
    session.clearOldFlashes();
    expect(session['key'], equals('value'));
    session.clearOldFlashes();
    expect(session['key'], equals(null));
  }

  @test
  it_has_an_id() {
    expect(session.id, equals('id'));
  }
}

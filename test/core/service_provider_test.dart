import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';

class ServiceProviderTest implements TestCase {
  setUp() {}

  tearDown() {}

  @test
  it_can_have_dependencies() async {
    final first = new FirstServiceProvider();
    final second = new SecondServiceProvider();
    expect(first.hasDependencies, isFalse);
    expect(second.hasDependencies, isTrue);
    expect(second.dependsOn(FirstServiceProvider), isTrue);
    expect(first.dependsOn(SecondServiceProvider), isFalse);
    expect(second.dependsOn(SecondServiceProvider), isFalse);
    expect(first.dependencies(), equals([]));
    expect(second.dependencies(), equals([FirstServiceProvider]));
  }

  @test
  it_inherits_the_dependencies_of_the_dependencies() {
    final third = new ThirdServiceProvider();
    expect(third.dependencies(),
        equals([SecondServiceProvider, FirstServiceProvider]));
  }

  @test
  it_cant_depend_on_itself() {
    final sixth = new SixthServiceProvider();
    final seventh = new SeventhServiceProvider();
    expect(sixth.dependencies(),
        equals([SeventhServiceProvider, FirstServiceProvider]));
    expect(seventh.dependencies(),
        equals([SixthServiceProvider, FirstServiceProvider]));
  }

  @test
  it_has_strict_and_non_strict_dependencies() {
    final fourth = new FourthServiceProvider();
    expect(fourth.dependencies(), equals([
      FirstServiceProvider, FifthServiceProvider,
      ThirdServiceProvider, SecondServiceProvider
    ]));
    expect(fourth.dependencies(strict: true), equals([
      FirstServiceProvider
    ]));
  }
}

class FirstServiceProvider extends ServiceProvider {}

@DependsOn(FirstServiceProvider)
class SecondServiceProvider extends ServiceProvider {}

@DependsOn(SecondServiceProvider)
class ThirdServiceProvider extends ServiceProvider {}

@DependsOn(FirstServiceProvider)
@DependsOn(FifthServiceProvider, strict: false)
class FourthServiceProvider extends ServiceProvider {}

@DependsOn(ThirdServiceProvider)
class FifthServiceProvider extends ServiceProvider {}

@DependsOn(SeventhServiceProvider)
class SixthServiceProvider extends ServiceProvider {}

@DependsOn(SixthServiceProvider)
@DependsOn(FirstServiceProvider)
class SeventhServiceProvider extends ServiceProvider {}

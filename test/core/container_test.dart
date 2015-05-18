import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'dart:async';

class ContainerTest implements TestCase {

  Container container;

  setUp() {
    container = new Container();
  }

  tearDown() {
  }

  @test
  it_instantiates_a_class() {
    expect(container.make(DeCoupledClass) is DeCoupledClass, isTrue);
  }

  @test
  it_instantiates_the_dependencies_of_the_class() {
    expect(container.make(ClassDependingOnClass) is ClassDependingOnClass, isTrue);
  }

  @test
  it_throws_an_exception_when_cant_instantiate() {
    expect(new Future.microtask(() => container.make(Interface)), throws);
  }

  @test
  it_binds_an_implementing_class_to_an_interface() {
    container.bind(Interface, ClassImplementingInterface);

    expect(container.make(Interface) is ClassImplementingInterface, isTrue);
  }

  @test
  it_resolves_a_functions_arguments() {
    var closure = (DeCoupledClass d) => d;

    expect(container.resolve(closure) is DeCoupledClass, isTrue);
  }
}

class DeCoupledClass {
}

class ClassDependingOnClass {
  DeCoupledClass dependency;

  ClassDependingOnClass(DeCoupledClass this.dependency);
}

abstract class Interface {
}

class ClassImplementingInterface implements Interface {
}

class ClassDependingOnInterface {
  Interface dependency;

  ClassDependingOnInterface(Interface this.dependency);
}
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
    expect(container.make(LonelyClass) is LonelyClass, isTrue);
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
    var closure = (LonelyClass d) => d;

    expect(container.resolve(closure) is LonelyClass, isTrue);
  }

  @test
  it_binds_an_instance_as_a_singleton() {
    var instance = new LonelyClass();
    container.singleton(instance);

    expect(container.make(LonelyClass) == instance, isTrue);
  }

  @test
  it_binds_a_singleton_to_an_interface() {
    var instance = new ClassImplementingInterface();
    container.singleton(instance, as: Interface);

    expect(container.make(Interface) == instance, isTrue);
  }
}

class LonelyClass {
}

class ClassDependingOnClass {
  LonelyClass dependency;

  ClassDependingOnClass(LonelyClass this.dependency);
}

abstract class Interface {
}

class ClassImplementingInterface implements Interface {
}

class ClassDependingOnInterface {
  Interface dependency;

  ClassDependingOnInterface(Interface this.dependency);
}
part of bridge.core;

/// **Bridge Service Provider**
///
/// The Service Provider can implement a few methods,
/// which, in turn, will be called by the application.
/// These methods support method injection.
///
/// The Service Provider will be instantiated with
/// dependency injection. However, given the reason
/// for the Service Provider's existence, only
/// classes from the local library, or core classes, should
/// be injected in the constructor. Dependencies from other libraries
/// might not yet have been bound into the container at
/// that point. Instead, those dependencies should be
/// injected into the `load` method of the Service Provider.
///
/// **The lifecycle**
///
/// When the [Application] is being set up, it will load
/// all Service Providers registered in the configuration.
/// Then, the following methods will be called, in turn:
///
///     setUp
/// This method should be used to bind implementations
/// of interfaces into the IoC container.
///
///     load
/// This method should be used to integrate the service
/// with other services set up in the application.
///
///     run
/// This method should be used to respond to the integration
/// performed be other Service Providers into this service.
///
///     tearDown
/// This method is called when the `exit` command has been issued
/// in the shell program.
///
/// A Service Provider can depend on other Service Providers, by annotating with
/// [DependsOn] that takes a [Type]. If the dependency is not necessary for the
/// service to function, the parameter `strict` can be set to false
///
/// **Example**
///
/// A service provider should be structured like this:
///
///     @DependsOn(MyOtherServiceProvider)
///     @DependsOn(HttpServiceProvider, strict: false)
///     class MyServiceProvider extends ServiceProvider {
///       Application app;
///       MySingleton singleton;
///
///       MyServiceProvider(Application this.app);
///
///       setUp(MySingleton singleton) {
///         app.singleton(singlet on);
///         this.singleton = singleton;
///
///         app.bind(MyInterface, MyClass);
///       }
///
///       load(ExternalLibraryClass external, MyInterface myObject) {
///         external.interact(myObject);
///       }
///
///       run() {
///         singleton.interactWithOtherLibrariesThatUsedThisSingleton();
///       }
///
///       tearDown() {
///         singleton.stopSomeRunningService();
///       }
///     }
abstract class ServiceProvider {
  InstanceMirror _self;
  Set<Type> _allDependencies;
  Set<Type> _strictDependencies;

  ServiceProvider() {
    _self = reflect(this);
  }

  bool get hasDependencies => dependencies().isNotEmpty;

  bool dependsOn(Type other) => dependencies().contains(other);

  Set<Type> dependencies({bool strict: false}) =>
      strict ?
      _strictDependencies ??= _getDependenciesOf(_self.type, strict)
          :
      _allDependencies ??= _getDependenciesOf(_self.type, strict);

  Set<Type> _getDependenciesOf(ClassMirror mirror, bool strict) {
    return mirror.metadata
        .where((m) => m.reflectee is DependsOn)
        .map((m) => _dependOn(m.reflectee, strict))
        .expand((d) => d)
        .toList(growable: false).toSet();
  }

  Set<Type> _dependOn(DependsOn depends, bool strict) {
    if (depends.dependency == this.runtimeType) return new Set();
    final isStrict = strict && depends.strict;
    if (strict && !isStrict)
      return new Set();
    return new Set.from([depends.dependency])
      ..addAll(_getDependenciesOf(reflectClass(depends.dependency), isStrict));
  }
}

class DependsOn {
  final Type dependency;
  final bool strict;

  const DependsOn(this.dependency, {this.strict: true});
}

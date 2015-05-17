part of bridge.core;

/// **Bridge Core Service Provider Interface**
///
/// This interface has no abstract methods. It only
/// acts as an identifier when importing Service
/// Providers into the application.
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
/// **Example**
///
/// A service provider should be structured like this:
///
///     class MyServiceProvider implements ServiceProvider {
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
abstract class ServiceProvider {}
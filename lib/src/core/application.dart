part of bridge.core;

/// **Bridge Core Application**
///
/// Wraps a [Container] instance and handles the server controller.
/// The Application is the active IoC container of a Bridge app,
/// and is responsible for running all the service providers
/// when the program is started.
class Application implements Container {
  final Container _container = new Container();

  Config _config;

  List<ServiceProvider> _serviceProviders = [];

  Application() {
    _container.singleton(this);
    _container.singleton(this, as: Container);
  }

  List<ServiceProvider> get serviceProviders => _serviceProviders;

  bool hasServiceProvider(Type type) {
    return serviceProviders.any((s) => s.runtimeType == type);
  }

  /// An easy accessor to the global [Config] object, which can also
  /// easily be resolved through the container:
  ///
  ///     application.config;
  ///
  /// is equal to
  ///
  ///     application.make(Config);
  Config get config => _config;

  /// Binds an abstract class to an implementation, so that the
  /// non-abstract class will be injected when the
  /// abstraction is requested.
  void bind(Type abstraction, Type implementation) =>
      _container.bind(abstraction, implementation);

  /// Creates a new instance of a class, while injecting its
  /// dependencies recursively. Assign to a typed variable:
  ///
  ///     Config config = application.make(Config);
  ///
  /// Optionally provide named parameters to be inserted
  /// in the constructor invocation.
  ///
  ///     class MyClass {
  ///       MyClass(Config config, {String myString}) {
  ///         ...
  ///       }
  ///     }
  ///
  ///     application.make(MyClass, namedParameters: {'myString': 'value'});
  make(Type type, {Map<String, dynamic> namedParameters,
  Map<Type, dynamic> injecting}) =>
      _container.make(
          type, namedParameters: namedParameters, injecting: injecting);

  /// Resolves a method or a top-level function be injecting its
  /// arguments and their dependencies recursively
  ///
  ///     String getConfigItem(Config config) {
  ///       return config['file.key'];
  ///     }
  ///
  ///     application.resolve(getConfigItem); // 'value'
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  resolve(Function function, {Map<String, dynamic> namedParameters,
  Map<Type, dynamic> injecting}) =>
      _container.resolve(
          function, namedParameters: namedParameters, injecting: injecting);

  /// Binds an instance as a singleton in the container, so that every
  /// time a class of that type is requested, that instance will
  /// be injected instead.
  ///
  /// Optionally set the type to bind as. This is especially useful if you want
  /// to have a singleton instance of an abstract class.
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  void singleton(Object singleton, {Type as}) =>
      _container.singleton(singleton, as: as);

  /// Checks if an object has a method.
  bool hasMethod(Object object, String method) =>
      _container.hasMethod(object, method);

  /// Resolves a named method on an instance. Use only when the type is
  /// not known or when expects a subtype or an implementation.
  ///
  /// Otherwise, use [resolve].
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  resolveMethod(Object object, String methodName,
      {Map<String, dynamic> namedParameters,
      Map<Type, dynamic> injecting}) => _container.resolveMethod(
      object, methodName, namedParameters: namedParameters,
      injecting: injecting);

  /// Creates a function that can take any arguments. The arguments will
  /// then, by their type, be injected into the inner function when called,
  /// evaluating the inner function and returning the response.
  ///
  ///     functionWillBeInjected(SomeClass input) {}
  ///     Function curried = application.curry(functionWillBeInjected);
  ///     curried(...);
  curry(Function function,
      {Map<String, dynamic> namedParameters,
      Map<Type, dynamic> injecting}) => _container.curry(
      function, namedParameters: namedParameters, injecting: injecting);

  @Deprecated('in version 1.1. Use curry instead')
  presolve(Function function,
      {Map<String, dynamic> namedParameters,
      Map<Type, dynamic> injecting}) => _container.curry(
      function, namedParameters: namedParameters, injecting: injecting);

  /// Registers a decorator on a target type, so that every time that type
  /// is injected, it will be decorated with the decorator.
  ///
  /// That means a class can be decorated with multiple decorators.
  ///
  ///     class Parent {}
  ///
  ///     class Decorator implements Parent {
  ///       final Parent parent;
  ///
  ///       Decorator(this.parent);
  ///     }
  ///
  ///     application.decorate(Parent, decorator: Decorator);
  ///     application.make(Parent); // Instance of 'Decorator'
  void decorate(Type target,
      {Type decorator,
      Iterable<Type> decorators,
      Map<String, dynamic> namedParameters,
      Map<Type, dynamic> injecting}) => _container.decorate(
      target, decorator: decorator,
      namedParameters: namedParameters,
      injecting: injecting);

  /// Initialize the application, given a relative path to the directory where
  /// the config files are located.
  Future setUp(String configRoot) async {
    await _setUpConfig(configRoot);

    await _setUpServiceProviders();
  }

  Future setUpWithConfig(Config config) async {
    _config = config;

    await _setUpServiceProviders();
  }

  Future tearDown() async {
    await _runServiceProviderMethod('tearDown');
  }

  _setUpConfig(String configRoot) async {
    Directory configRootDirectory = new Directory(configRoot);
    if (!await configRootDirectory.exists()) {
      throw new InvalidArgumentException('$configRoot is not a directory');
    }
    _config = await Config.load(configRootDirectory);
    this.singleton(_config, as: Config);
    _setEnv(_config);
  }

  void _setEnv(Config config) {
    var env = config.env('APP_ENV', 'production');
    if (env == 'production') Environment.current = Environment.production;
    else if (env == 'development')
      Environment.current = Environment.development;
    else if (env == 'testing') Environment.current = Environment.testing;
    else Environment.current = Environment.custom;
  }

  _setUpServiceProviders() async {
    _registerServiceProviders();

    await _loadServiceProviders();
  }

  Future _loadServiceProviders() async {
    await _runServiceProviderMethod('setUp');

    await _runServiceProviderMethod('load');

    await _runServiceProviderMethod('run');
  }

  _registerServiceProviders() {
    List<String> providerPaths = config('app.service_providers', []);

    if (providerPaths == null) return;

    if (providerPaths is! List) throw new ConfigException(
        '[app.service_providers] must be a list');

    providerPaths.forEach((String serviceProviderPath) {
      List<String> serviceProviderPathSegments = serviceProviderPath.split('.');

      String serviceProviderName = serviceProviderPathSegments.removeLast();

      String libraryName = serviceProviderPathSegments.join('.');

      _registerServiceProvider(
          new Symbol(libraryName), new Symbol(serviceProviderName));
    });

    _checkDependencies();
  }

  _registerServiceProvider(Symbol libraryName, Symbol serviceClassName) {
    LibraryMirror library = currentMirrorSystem().findLibrary(libraryName);

    ClassMirror serviceClass = library.declarations[serviceClassName];

    if (serviceClass == null) throw new ConfigException(
        '${MirrorSystem.getName(serviceClassName)} does not exist');

    if (!serviceClass.isAssignableTo(reflectClass(ServiceProvider))) {
      String name = MirrorSystem.getName(serviceClassName);

      throw new ConfigException('$name is not a ServiceProvider');
    }
    _serviceProviders.add(this.make(serviceClass.reflectedType));
  }

  void _checkDependencies() {
    for (final provider in _serviceProviders)
      for (final dep in provider.dependencies(strict: true))
        if (!hasServiceProvider(dep))
          throw new MissingDependencyException(dep, provider);
  }

  Future _runServiceProviderMethod(String name) async {
    return Future.wait(_serviceProviders
        .where((s) => hasMethod(s, name))
        .map((s) => new Future.value(this.resolveMethod(s, name))));
  }
}

class MissingDependencyException extends BaseException {
  final Type dependency;
  final ServiceProvider serviceProvider;

  MissingDependencyException(dependency, serviceProvider)
      : dependency = dependency,
        serviceProvider = serviceProvider,
        super('[${_qualifiedPathOfObject(serviceProvider)}] '
          'needs [${_qualifiedPathOfType(dependency)}] to function');

  static String _qualifiedPathOfType(Type type) {
    return MirrorSystem.getName(reflectType(type).qualifiedName);
  }

  static String _qualifiedPathOfObject(Object object) {
    return _qualifiedPathOfType(object.runtimeType);
  }
}

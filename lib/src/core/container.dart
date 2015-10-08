part of bridge.core;

/// **Bridge Core IoC Container**
///
/// This class is responsible for all dependency injection and the like.
abstract class Container {
  factory Container() => new _Container();

  /// Creates a new instance of a class, while injecting its
  /// dependencies recursively. Assign to a typed variable:
  ///
  ///     Config config = container.make(Config);
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
  ///     container.make(MyClass, namedParameters: {'myString': 'value'});
  ///
  /// Optionally provide temporary singletons, to be injected if
  /// the constructor depends on a type.
  ///
  ///     class MyClass {
  ///       MyClass(MyInterface interface) {
  ///         ...
  ///       }
  ///     }
  ///
  ///     container.make(MyClass, injecting: {MyInterface: new MyImpl()});
  make(Type type,
       {Map<String, dynamic> namedParameters, Map<Type, dynamic> injecting});

  /// Resolves a method or a top-level function be injecting its
  /// arguments and their dependencies recursively
  ///
  ///     String getConfigItem(Config config) {
  ///       return config['file.key'];
  ///     }
  ///
  ///     container.resolve(getConfigItem); // 'value'
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  /// Optionally provide temporary singletons, to potentially be injected
  /// into the invocation.
  resolve(Function function,
          {Map<String, dynamic> namedParameters, Map<Type, dynamic> injecting});

  /// Resolves a named method on an instance. Use only when the type is
  /// not known or when expects a subtype or an implementation.
  ///
  /// Otherwise, use [resolve].
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  /// Optionally provide temporary singletons, to potentially be injected
  /// into the invocation.
  resolveMethod(Object object, String methodName,
                {Map<String, dynamic> namedParameters, Map<Type, dynamic> injecting});

  /// Checks if an object has a method.
  ///
  /// **NOTE:** This does not guarantee that the method will successfully
  /// be resolved, only that the method exists. This behaviour may change.
  bool canResolveMethod(Object object, String method);

  /// Binds an instance as a singleton in the container, so that every
  /// time a class of that type is requested, that instance will
  /// be injected instead.
  ///
  /// Optionally set the type to bind as. This is especially useful if you want
  /// to have a singleton instance of an abstract class.
  ///
  /// Optionally provide named parameters to be inserted in the invocation.
  /// Optionally provide temporary singletons, to potentially be injected
  /// into the invocation.
  void singleton(Object singleton, {Type as});

  /// Binds an abstract class to an implementation, so that the
  /// non-abstract class will be injected when the
  /// abstraction is requested.
  void bind(Type abstraction, Type implementation);

  /// Creates a function that can take any arguments. The arguments will
  /// then, by their type, be injected into the inner function when called,
  /// evaluating the inner function and returning the response.
  ///
  ///     functionWillBeInjected(SomeClass input) {}
  ///     Function presolved = container.presolve(functionWillBeInjected);
  ///     presolved(...);
  Function presolve(Function function,
                    {Map<String, dynamic> namedParameters,
                    Map<Type, dynamic> injecting});
}

class _Container implements Container {
  Map<Type, dynamic> _singletons = {};
  Map<Type, Type> _bindings = {};

  void bind(Type abstraction, Type implementation) {
    _bindings[abstraction] = implementation;
  }

  void singleton(Object singleton, {Type as}) {
    Type type = (as == null) ? singleton.runtimeType : as;

    _singletons[type] = singleton;
  }

  make(Type type,
       {Map<String, dynamic> namedParameters,
       Map<Type, dynamic> injecting}) {
    if (_singletons.containsKey(type)) return _singletons[type];

    if (_bindings.containsKey(type)) type = _bindings[type];

    return _make(type, namedParameters, injecting);
  }

  resolve(Function function,
          {Map<String, dynamic> namedParameters,
          Map<Type, dynamic> injecting}) {
    ClosureMirror closure = reflect(function);

    List positional = _getPositionalParameters(closure.function, injecting);

    return closure.apply(
        positional, _convertStringKeysToSymbols(namedParameters)).reflectee;
  }

  _make(Type type,
        Map<String, dynamic> namedParameters,
        Map<Type, dynamic> injecting) {
    try {
      var namedArguments = _convertStringKeysToSymbols(namedParameters);

      ClassMirror classMirror = reflectType(type);

      Symbol constructorSymbol;

      List positionalArguments;

      if (classMirror.declarations.containsKey(classMirror.simpleName)) {
        MethodMirror constructor =
        classMirror.declarations[classMirror.simpleName];

        positionalArguments = _getPositionalParameters(constructor, injecting);

        constructorSymbol = constructor.constructorName;
      } else {
        positionalArguments = [];

        constructorSymbol = const Symbol('');
      }

      final instance = (classMirror.newInstance(
          constructorSymbol,
          positionalArguments,
          namedArguments)
      ).reflectee;

      if (canResolveMethod(instance, r'$inject'))
        resolveMethod(instance, r'$inject');

      return instance;
    } catch (error) {
      throw new ContainerException(type, error);
    }
  }

  Map<Symbol, dynamic> _convertStringKeysToSymbols(Map<String, dynamic> map) {
    if (map == null) return {};

    return new Map<Symbol, dynamic>.fromIterables(
        map.keys.map((String key) => new Symbol(key)), map.values);
  }

  List _getPositionalParameters(
      MethodMirror method, Map<Type, dynamic> injecting) {
    List positionalParameters = [];

    if (method == null) return positionalParameters;

    method.parameters.forEach((ParameterMirror parameter) {
      if (!parameter.isNamed) {
        if (!parameter.type.hasReflectedType) throw new InvalidArgumentException(
            'Each parameter must be typed in order to resolve the method!');

        var type = parameter.type.reflectedType;

        if (injecting != null && injecting.containsKey(type)) {
          return positionalParameters.add(injecting[type]);
        }

        positionalParameters.add(make(type, injecting: injecting));
      }
    });

    return positionalParameters;
  }

  resolveMethod(Object object, String methodName,
                {Map<String, dynamic> namedParameters, Map<Type, dynamic> injecting}) {
    var symbol = new Symbol(methodName);

    var instance = reflect(object);

    var objectClass = instance.type;

    var method = objectClass.declarations[symbol];

    var args = _getPositionalParameters(method, injecting);

    return instance.invoke(
        symbol, args, _convertStringKeysToSymbols(namedParameters)).reflectee;
  }

  bool canResolveMethod(Object object, String method) {
    return reflect(object).type.declarations.containsKey(new Symbol(method));
  }

  Function presolve(Function function,
                    {Map<String, dynamic> namedParameters,
                    Map<Type, dynamic> injecting}) {
    return ([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10]) {
      var arguments = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10]
      .where((a) => a != null);

      var argumentsWithTypes = ((injecting != null ? injecting : {}) as Map)
        ..addAll(new Map.fromIterables(
          arguments.map((a) => a.runtimeType),
          arguments));

      return resolve(function, injecting: argumentsWithTypes, namedParameters: namedParameters);
    };
  }
}

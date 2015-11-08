# Bridge Framework Changelog

This Changelog tracks changes in all releases across the [dart-bridge](https://github.com/dart-bridge) organization.

---

## [framework](https://github.com/dart-bridge/framework)/1.0.0-beta.3

### Changes
* [`bridge.http`] Add a middleware that transform `<form method>` with methods `PUT`, `PATCH`, `UPDATE`, or `DESTROY`
  to hidden inputs:
  
```html
<form method='PATCH'>
<!-- transformed to -->
<form method='POST'><input type='hidden' name='_method' value='PATCH'>
```

* [`bridge.tether`] `Tether#listen` now returns a `StreamSubscription`, so that a listener can be cancelled easily.

### Bug fixes
* [`bridge.core`] Fixed a bug where a `.env` file was required for anything to work.

## [framework](https://github.com/dart-bridge/framework)/1.0.0-beta.2
This release fixed some bugs, but mainly it's accounting for breaking changes in Trestle.

### Changes
* [`bridge.database`] Updated to Trestle 0.6.0.

### Bug fixes
* [`bridge.view`] Fixed a bug where line breaks in template cache wasn't being accounted for on Windows.

## [trestle](https://github.com/dart-bridge/trestle)/0.6.0
This release of Trestle introduces relationship annotations, value object models, and some other changes.
See the Readme over at [the Trestle repo](https://github.com/dart-bridge/trestle#orm).

### Changes
* `Repository#add`, `Repository#addAll`, and `Repository#update` are now deprecated, in favor of the unified
  `Repository#save` and `Repository#saveAll` methods.

* Repositories can now use value objects as models:

```dart
// These three are somewhat equivalent.

class DataStructure { String name; }

class ValueObject {
  final String name;
  const ValueObject(this.name);
}

class SomeModel extends Model { @field String name; }
```

### Breaking changes
* The Gateway is now being passed into Repositories in the constructor (only breaking for people using Trestle
  without Bridge).

```dart
// 0.5.8
new Repository<MyModel>()
  ..connect(gateway);

// 0.6.0
new Repository<MyModel>(gateway);
```

* Model fields are now automatically snake cased, which may only be an issue if a field like `myField` correlates
  with a table column in the same format. After updating to `0.6.0`, that field would be expected to map over to a
  column called `my_field`.

```dart
class MyModel extends Model {
  // These are superfluous
  @field String my_field;
  @Field('my_field') String myField;

  // This is the correct format
  @field String myField;
}

class MyDataStructure {
  // Superfluous
  String my_field;

  // Correct
  String myField;
}
```

* Overridden table names are now stored on the model class instead of as a Repository getter.

```dart
// 0.8.5
class MyRepository extends Repository<MyModel> {
  String get table => 'overridden_table';
}

// 0.6.0
class MyModel {
  static const table = 'overridden_table';
}
```

## [framework](https://github.com/dart-bridge/framework)/1.0.0-beta.1
The beta release of Bridge marks the beginning of this Changelog. Refer to
[dart-bridge.io/docs](http://dart-bridge.io/docs) for documentation up to this point.

# Roadmap

This is a list of priorities for the project, associated with a target version. If you have feature requests, please
join our [Gitter channel](https://gitter.im/dart-bridge/framework) and raise your voice!

---

## Pre 1.0


### Alpha 7

#### `bridge.view`
* **Rewrite**: The templating engine needs a more scalable structure, as well as a more secure tokenizer solution.
* **Deprecation**: Jade will no longer be supported, as it is not really compatible with Dart in the same way as with
  JavaScript. Bridge templates will be used instead. Jade will however be available as a standalone package.
* **Naming**: Come up with a name for the Bridge templates, and use a custom extension like `.x.html` for a more
  predictable behaviour.

#### `bridge.http`
* **Rewrite**: The entire middleware structure should be decoupled, including handling `Session`, `Input`, and exception
  handling.
* **Rewrite/Feature**: (#7) Extend the `Router` to account for the changes in architecture, as well as adding more
  functionality, potentially by wrapping a community driven router like 
  [shelf_route](https://pub.dartlang.org/packages/shelf_route).

#### `bridge.events`
* **Rewrite**: Rewrite this small library into something more robust.
* **Interop**: Add domain events in the other components (`bridge.database`, `bridge.http`)

### Beta
The Beta will be entered as soon as the public API is solidified. No more features or breaking changes will be accepted
at this point. A new branch will be created to host `1.1` features instead.

#### `bridge.tether`
* **Feature**: Align the Tethers and the Sessions from `bridge.http`, to create a platform for authentication.

#### `bridge.cli`
* **Support**: Windows support! Must be solved in the [Cupid](https://github.com/emilniklas/cupid) package.


### 1.0

#### General
* Make screencasts.
* Complete the documentation site at [dart-bridge.io](http//dart-bridge.io).
* Start a changelog, with the docs as the starting point.

---

## Post 1.0


### 1.1

...
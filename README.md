[![Bridge](http://dart-bridge.io/bridge-cover.svg)](http://dart-bridge.io)

[![Build Status](https://img.shields.io/travis/dart-bridge/framework.svg)](https://travis-ci.org/dart-bridge/framework)
[![Coverage Status](https://img.shields.io/coveralls/dart-bridge/framework.svg)](https://coveralls.io/r/dart-bridge/framework)
[![Pub Status](https://img.shields.io/pub/v/bridge.svg)](https://pub.dartlang.org/packages/bridge)
[![License](https://img.shields.io/github/license/dart-bridge/framework.svg)](https://pub.dartlang.org/packages/bridge)

[![Join the chat at https://gitter.im/dart-bridge/framework](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dart-bridge/framework?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the framework repository. The application package is [here](http://github.com/dart-bridge/bridge).
Documentation is [here](http://dart-bridge.io).

---

# Bridge
_An end-to-end web app framework for Dart_

Dart is an amazing language. Not only for creating client side apps, but for servers as well. Since it works on both
sides, we have a huge opportunity as developers to maximize code reusability, and to once and for all _bridge the gap
between the server and the client_.

Bridge is an effort to streamline the experience of working with a Dart based back-end. Besides having facilities for
server side templating and other things you'd expect from a modern framework, it also provides an out-of-the-box
WebSocket abstraction called _Tether_. With this, we can seamlessly send data structures from server to client,
and client to server too!

---

## Getting started

This repository is the home for the framework itself. To create an application based on Bridge, complete these steps:

1. Install the [Dart SDK](https://www.dartlang.org/downloads).
2. Use [pub](https://pub.dartlang.org) (comes with the SDK) to activate the Bridge Installer:
   `pub global activate new_bridge`
3. Use the installer to create a new project:
   `new_bridge my_first_project` (This creates a folder in the current directory called "my_first_project")
4. Go into the newly created directory and start the Bridge CLI:
   `dart bridge`
5. Start the server (`start`) and visit [localhost:1337](http://localhost:1337). You can speed everything up by sending
   through the boot commands `start` and `watch` to start the server instantly, and restarting the app on each
   file save: `dart bridge start, watch`
   
---

## Contributing

Contributing to Bridge can be done in different ways. You can:

* Post issues on [this](https://github.com/dart-bridge/framework) repository if you encounter any bugs.
* Fork the repository, create a **failing** unit test, and make a pull request.
* Better yet, fix the issue yourself, and make the PR.
* Help with the documentation by posting pull requests to the [docs repo](https://github.com/dart-bridge/docs).

If you have feature requests, please join our [Gitter channel](https://gitter.im/dart-bridge/framework) and raise your
voice!

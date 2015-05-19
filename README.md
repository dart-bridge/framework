# Bridge
[![Build Status](https://travis-ci.org/emilniklas/dart-bridge.svg?branch=master)](https://travis-ci.org/emilniklas/dart-bridge)

Currently, this repo contains only the core library of Bridge.

You can watch [this](https://www.youtube.com/watch?v=-c90H03MXbg) video for
a preview of what's coming up.

*Documentation and unit tests for the core components are a priority.*

## Abstract

Modern web applications have to choose whether it should live in the browser, as a [SPA](http://en.wikipedia.org/wiki/Single-page_application), or on the server. The latter provide a more stable
environment. You only have to worry about the server's capabilities.

On the other hand, if you choose to place everything in JavaScript, client-side, you get a fast, responsive
experience, that doesn't rely on sending forms and documents back and fourth using [postback](http://en.wikipedia.org/wiki/Postback).

Previously, a **best-of-both-worlds**-scenario has been hard to maintain, as it involves sending data structures
using [AJAX](http://en.wikipedia.org/wiki/Ajax_%28programming%29), resulting in a fragmented experience, and often
involves duplicate classes representing the data structures on both sides of the border.
 
Recently, technologies have emerged which allow us more intuitive communication between server code and client code.
Consider the following two:

* Dart – a language that works both on the server and the client.
* [WebSockets](http://en.wikipedia.org/wiki/WebSocket), that allow us to swiftly **send and receive** messages in
  both the browser and on the server.
  
Using these technologies (and the above two in particular), **Bridge** is an attempt to close the gap between
the server and the client, without redundant pieces of code.

## Tether

The main feature of Bridge is **Tether**, which basically is a wrapper around the native Dart WebSocket class.
It has identical syntax on the server and on the client:

**_NOTE: NOT ACTUALLY IN THE REPO YET_**

```dart
class Controller implements HandlesTether {

  tether(Tether tether) async {
  
    String response = await tether.send('greeting', 'Hello, server!');
    
    print(response); // Hello, client!
  }
}
```

```dart
class Controller implements HandlesTether {

  tether(Tether tether) async {
  
    tether.listen('greeting', (String greeting) {
    
      print(greeting); // Hello, server!
    
      return 'Hello, client!';
    });
  }
}
```

## Getting started

1. Clone the barebone application repository

   **_NOT AVAILABLE YET_**

2. 
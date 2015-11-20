library bridge.tether.client;

import 'dart:async';
import 'dart:html';

import 'package:bridge/transport_client.dart';
import 'package:tether/http_client.dart';
import 'package:tether/protocol.dart';

import 'tether_shared.dart';

export 'tether_shared.dart';

Tether _globalTether = webSocketTether('ws://${window.location.hostname}:${window.location.port}/');

Tether get tether {
  Messenger.serializer = serializer;
  return _globalTether;
}

@Deprecated('1.0.0. Handle Tether connection manually')
Future globalTether() async {
  await _globalTether.onConnection;
}

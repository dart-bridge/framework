library bridge.tether.client;

import 'dart:async';
import 'dart:html';

import 'package:bridge/transport_client.dart';
import 'package:bridge/http_client.dart' as http;
import 'package:tether/http_client.dart';
import 'package:tether/protocol.dart';

import 'tether_shared.dart';

export 'tether_shared.dart';

Tether _globalTether;

Tether get tether {
  Messenger.serializer = serializer;
  Session.factory = (id, data) => new http.Session(id, data);
  return _globalTether ??= webSocketTether('ws://${window.location.hostname}:${window.location.port}/');
}

@Deprecated('1.0.0. Handle Tether connection manually')
Future globalTether() async {
  await tether.onConnection;
}

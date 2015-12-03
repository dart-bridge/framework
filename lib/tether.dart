library bridge.tether;

import 'dart:async';

import 'package:bridge/core.dart';
import 'package:bridge/http.dart' as http;
import 'package:bridge/transport.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart' as ws;
import 'package:tether/protocol.dart';

export 'tether_shared.dart';
import 'tether_shared.dart';

part 'src/tether/tether_service_provider.dart';

@Deprecated('1.0.0. Use [Tethers] instead')
class TetherManager {
  final Tethers _tethers;

  TetherManager(this._tethers);

  void add(Anchor anchor) => _tethers.add(anchor);

  void broadcast(String key, [data]) => _tethers.broadcast(key, data);

  Tether fromSession(Session session) => _tethers.get(session);

  void registerHandler(handler(Tether tether)) => _tethers.registerHandler(handler);
}